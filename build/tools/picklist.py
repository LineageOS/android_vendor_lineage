#!/usr/bin/env python3
import argparse
import collections
import json
import os, os.path
import requests
import subprocess
import sys
import time

try:
    import yaml
except ModuleNotFoundError:
    print('Error: you need to install PyYAML. Try `sudo apt install python3-yaml`, or similar.')
    sys.exit(1)

from multiprocessing.pool import Pool, ThreadPool
from xml.etree import ElementTree

if not hasattr(subprocess, 'run'):
    print('Error: This script requires subprocess.run, please upgrade to Python >= 3.5', file=sys.stderr)
    sys.exit(2)

# preserve yaml object order, https://stackoverflow.com/a/21048064
_mapping_tag = yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG

def dict_representer(dumper, data):
    return dumper.represent_dict(data.items())

def dict_constructor(loader, node):
    return collections.OrderedDict(loader.construct_pairs(node))

yaml.add_representer(collections.OrderedDict, dict_representer)
yaml.FullLoader.add_constructor(_mapping_tag, dict_constructor)

DEBUG = False
def debug(*args, **kwargs):
    if DEBUG:
        print(*args, **kwargs)

class PickStep:
    def __init__(self, force):
        self.force = force
        self.changes = {}

    def add_change(self, path, num, subj):
        if path not in self.changes:
            self.changes[path] = []
        self.changes[path].append((num, subj))

    def generate_yaml(self, gen):
        if self.force:
            gen.add_line('_args: [\'-f\']')
        for project in sorted(self.changes.keys()):
            gen.add_line('{}:'.format(project))
            gen.indent()
            for num, subj in self.changes[project]:
                if num == -1:
                    gen.add_line('# Change skipped - not on gerrit: {}'.format(subj))
                else:
                    gen.add_line('- {} # {}'.format(num, subj))
            gen.deindent()

class YamlGen:
    def __init__(self):
        self._indent = 0
        self.output = ''

    def indent(self):
        self._indent += 2

    def deindent(self):
        self._indent -= 2
        assert self._indent >= 0

    def add_line(self, line):
        self.output += (' ' * self._indent) + line + '\n'


class Picklist:
    def __init__(self):
        self.project_pos = {}
        self.steps = []

    def _get_step_after(self, index, force, num):
        for k in range(index, len(self.steps)):
            # change number is -1 means the change is bogus, don't
            # put it any further ahead than we have to.
            if num == -1 or self.steps[k].force == force:
                return k
        self.steps.append(PickStep(force))
        return len(self.steps) - 1

    def add_change(self, path, num, force, subj):
        # get position of picklist to use
        pos = self._get_step_after(self.project_pos.get(path, 0), force, num)
        # add change to the right picklist
        self.project_pos[path] = pos
        self.steps[pos].add_change(path, num, subj)

    def generate_yaml(self):
        gen = YamlGen()
        # this is really awful, but the simplest way to
        # output comments in the yaml without
        # requiring any additional dependencies
        for i, step in enumerate(self.steps):
            gen.add_line('step_{:02d}{}:'.format(i, '_force' if step.force else ''))
            gen.indent()
            step.generate_yaml(gen)
            gen.deindent()

        return gen.output


class Repo:
    ''' represents a single repo in the tree. '''
    def __init__(self, path, topdir):
        self.path = path
        self.topdir = topdir

    def _run(self, *args, **kwargs):
        ''' run a command in this repo dir '''
        os.chdir(os.path.join(self.topdir, self.path))
        if 'text' not in kwargs:
            kwargs['text'] = True
        if 'capture_output' not in kwargs:
            kwargs['capture_output'] = True
        debug('cwd={}, args={}, kwargs={}'.format(os.getcwd(), args, kwargs))
        proc = subprocess.run(*args, **kwargs)
        os.chdir(self.topdir)
        return proc

    def get_upstream_rev(self):
        ''' get the current upstream revision for this repo '''
        proc = self._run(['repo', 'info', '.'])
        if proc.returncode != 0:
            # repo info seems to crash sometimes, don't fail.
            print('repo info {} failed: {}'.format(self.path, proc.returncode), file=sys.stderr)
            # just assume no changes in this repo.
            return self.get_cur_head()

        rev = None
        for line in proc.stdout.split('\n'):
            if line.startswith('Current revision: '):
                rev = line.split()[2]
                break

        if rev is None:
            raise ValueError('failed to parse repo info output')
        return rev

    def get_cur_head(self):
        ''' get the current HEAD revision for this repo '''
        proc = self._run(['git', 'rev-parse', 'HEAD'])
        if proc.returncode != 0:
            raise RuntimeError('git rev-parse HEAD in {} failed: {}'.format(self.path, proc.returncode))

        return proc.stdout.strip()

    def checkout(self, rev):
        ''' checkout the given revision in this repo '''
        ret = subprocess.run(['git', 'checkout', rev])
        return ret.returncode

    def reset_hard(self):
        ''' hard-reset this repo '''
        return self._run(['git', 'reset', '--hard']).returncode

    def is_ahead(self, rev):
        ''' returns True if HEAD in this repo is a descendant of the given rev '''
        # git merge-base --is-ancestor returns 0 if 'rev' is an ancestor of HEAD.
        return self._run(['git', 'merge-base', '--is-ancestor', rev, 'HEAD']).returncode == 0

    def get_commits_since(self, rev):
        ''' returns a list of dicts, where each dict represents a commit between HEAD and rev '''
        # this outputs commits like this:
        # <shasum> <subject>\n
        # <body> (over several lines, possibly)\n
        # <shasum again (used as a trailer, under the [clearly naive] assumption that this can't happen)>\n
        proc = self._run(['git', 'log', '--no-decorate', '--pretty=format:%H %s%n%b%n%H', '{}..HEAD'.format(rev)])

        if proc.returncode != 0:
            raise RuntimeError('git log in {} failed: {}'.format(self.path, proc.returncode))
        commits = []
        cur_commit = {}
        if proc.stdout.strip() == '':
            return []
        for line in proc.stdout.split('\n'):
            if 'sha' not in cur_commit:
                parts = line.split(' ', 1)
                print(line)
                cur_commit['sha'] = parts[0]
                cur_commit['subject'] = parts[1]
                cur_commit['body'] = ''
            elif line == cur_commit['sha']:
                # figure out the change-id - just find the last one in the commit
                # and go with that.
                body = cur_commit['body'].split()
                for j,t in enumerate(reversed(body)):
                    if t == 'Change-Id:':
                        cur_commit['change-id'] = body[len(body) - j]
                        break
                if 'change-id' not in cur_commit:
                    print('{} commit {} has no change-id, refusing to run on this repo!'.format(self.path, cur_commit['sha']), file=sys.stderr)
                    return []
                commits.append(cur_commit)
                cur_commit = {}
            else:
                cur_commit['body'] += line + '\n'

        return commits

class Gerrit:
    def __init__(self, url='https://review.lineageos.org'):
        self.gerrit_base = url

    def _get(self, path, params={}):
        ret = requests.get(self.gerrit_base + path, params=params)
        text = ret.text[4:] # strip 'magic' prefix line
        return json.loads(text)

    def query(self, q, count=None, skip=None):
        return self._get('/changes/', params={'q': q, 'n': count, 'S': skip})

    def get_changes_from_ids(self, change_ids, branch, project):
        # limit to a maximum of 50 changes per query (2 for branch/project)
        GERRIT_MAX_CHANGES = 50
        query_prefix = 'branch:{} project:{} ('.format(branch, project)
        query_suffix = ')'
        while len(change_ids) > 0:
            query_changes = []
            order = []
            for i in range(0, min(len(change_ids), GERRIT_MAX_CHANGES)):
                changeid = change_ids.pop(0)
                order.append(changeid)
                query_changes.append('change:{}'.format(changeid))

            obj = self.query('{}{}{}'.format(query_prefix, ' OR '.join(query_changes), query_suffix), count=GERRIT_MAX_CHANGES)

            obj = {o['change_id']: o for o in obj}

            for c in order:
                if c in obj:
                    yield obj[c]
                else:
                    dd = collections.defaultdict(lambda: -1)
                    dd['change_id'] = c
                    yield dd

class RepoManifest:
    def __init__(self):
        proc = subprocess.run(['repo', 'manifest'], capture_output=True, text=True)
        if proc.returncode != 0:
            raise RuntimeError('repo manifest failed: {}'.format(proc.returncode))
        manifest_str = proc.stdout
        # parse the manifest XML, and convert it into python data structures
        self.xml = ElementTree.fromstring(manifest_str)
        self.default_remote, self.default_rev = self._parse_defaults()
        self.remotes = self._parse_remotes()
        self.projects = self._parse_projects()

    def _parse_defaults(self):
        default = self.xml.findall('default')[0]
        return (default.get('remote'), default.get('revision'))

    def _parse_remotes(self):
        remotes = {}
        for remote in self.xml.findall('remote'):
            remotes[remote.get('name')] = {
                    'review': remote.get('review'),
                    'revision': remote.get('revision', self.default_rev),
            }

        return remotes

    def _parse_projects(self):
        projects = {}
        for project in self.xml.findall('project'):
            remote = project.get('remote', self.default_remote)
            revision = project.get('revision', self.remotes[remote]['revision'])
            if project.get('path') is None:
                continue
            projects[project.get('path')] = {
                    'name': project.get('name'),
                    'remote': remote,
                    'revision': revision,
            }
        return projects

    def get_branch(self, path):
        return self.projects[path]['revision']

    def get_project_name(self, path):
        return self.projects[path]['name']

    def get_project_paths(self):
        return set(self.projects.keys())

TOP = None
def gettop():
    ''' return path to root of the android tree '''
    global TOP
    if TOP is not None:
        return TOP
    old = os.getcwd()
    while not os.path.exists('build/make/core/envsetup.mk'):
        os.chdir('..')
        if os.getcwd() == '/':
            TOP = False
            return False
    TOP = os.getcwd()
    os.chdir(old)
    return TOP

def gotop(path=''):
    ''' go to path relative to TOP '''
    os.chdir(os.path.join(gettop(), path))

pick_counts = {}
def run_repopick(changes, path=None, extra_args=[]):
    ''' repopick the given changes to the given path. '''
    global pick_counts
    top = gettop()
    args = ['{}/vendor/lineage/build/tools/repopick.py'.format(top)]

    args += ['-c', pick_counts.get(path, 0) + (len(changes) * 2)]
    if path:
        args += ['-P', path]
        if path in pick_counts:
            pick_counts[path] += len(changes) * 2
        else:
            pick_counts[path] = len(changes) * 2

    args += extra_args
    args += changes
    args = list(map(str, args))

    res = subprocess.run(args, capture_output=True, text=True)
    if res.returncode != 0:
        return (False, res)
    else:
        return (True, res)

def parse_picklist(path):
    ''' load a picklist. '''
    try:
        with open(path) as f:
            text = f.read()
    except FileNotFoundError as e:
        if path.startswith('http://') or path.startswith('https://'):
            # try requests
            print('Going to try and fetch {}...'.format(path))
            req = requests.get(path)
            req.raise_for_status()
            text = req.text
            print('Got it!')
        else:
            raise e
    changes = yaml.load(text, Loader=yaml.FullLoader)
    return changes

def run_picklist(obj, ok_repos=None, jobs=4):
    ''' pick all changes specified in a given picklist. '''
    def run_project_changes(pair):
        ''' run repopick for the given project '''
        path, changes = pair
        # mark this repo as running.
        states[path] = 'run'
        ret, res = run_repopick(changes, path, args)
        state = 'ok' if ret else 'fail'
        states[path] = state
        if state == 'fail':
            # print out failures as they happen.
            print('{}: stdout:\n{}\n====stderr====\n{}'.format(path, res.stdout, res.stderr))

    for (group, projects) in obj.items():
        args = projects.pop('_args', [])
        # restrict repo list to repos that user has specified
        if ok_repos:
            projects = {k:v for k, v in projects.items() if k in ok_repos}
        states = {p: 'wait' for p in projects.keys() }
        with ThreadPool(jobs) as p:
            p.map_async(run_project_changes, projects.items(), 1)

            # show a "nice" progress bar while we're waiting for all the
            # repopick instances to finish.
            spinner = '|/-\\'
            spin = 0
            while len([p for p, v in states.items() if v in ['run', 'wait']]) > 0:
                complete = len([p for p, v in states.items() if v in ['ok', 'fail']])
                print('Running... {}/{} {}'.format(complete, len(states.items()), spinner[spin]), end='\r')
                spin += 1
                spin %= len(spinner)
                time.sleep(0.3)

        failed = [p for p, v in states.items() if v == 'fail']
        if failed:
            print('These projects in {} failed to pick: {}'.format(group, ' '.join(sorted(failed))))
            return False
        else:
            print('{}: All projects OK.'.format(group))

def reset_repo(repo_path, hard=False):
    ''' reset a repo to the upstream HEAD '''
    repo = Repo(repo_path, gettop())
    rev = repo.get_upstream_rev()
    if hard:
        if repo.reset_hard() != 0:
            raise RuntimeError('failed to reset --hard {}'.format(repo_path))

    cur_rev = repo.get_cur_head()
    if cur_rev == rev:
        print('{}: Already at upstream revision {}.'.format(repo_path, rev))
        return True

    print('{}: Checkout revision {}.'.format(repo_path, rev))
    ret = repo.checkout(rev)
    return ret == 0

def reset_all(repos, **kwargs):
    ''' reset all the given repos '''
    for repo in sorted(repos):
        reset_repo(repo, **kwargs)

def apply_picklist(args, ok_repos):
    ''' apply a given picklist '''
    reset_repos = set(['_args'])
    for arg in args.picklist:
        picklist = parse_picklist(arg)
        if args.checkout_upstream != 'no':
            # if we're resetting, figure out which projects haven't been
            # reset by an earlier picklist.
            repos = set().union(*[projects.keys() for (_, projects) in picklist.items()])
            to_reset = repos - reset_repos
            if ok_repos:
                # and filter down to projects specified with --repo.
                to_reset = ok_repos.intersection(to_reset)
            reset_all(to_reset, hard=args.checkout_upstream == 'hard')
            reset_repos.update(repos)
        # run this picklist!
        ok = run_picklist(picklist, ok_repos, args.jobs)
        if not ok:
            sys.exit(1)

gerrit = None
manifest = None

def get_extra_changes(path):
    ''' get changes numbers a path has over its HEAD '''
    project = manifest.get_project_name(path)
    branch = manifest.get_branch(path)
    repo = Repo(path, gettop())

    upstream_rev = repo.get_upstream_rev()
    if not repo.is_ahead(upstream_rev):
        raise RuntimeError('repo {} does not have upstream revision ({}) in history of HEAD, aborting.'.format(path, upstream_rev))

    commits = repo.get_commits_since(upstream_rev)
    if not commits:
        return []
    print('{}: Got {} commits to fetch from gerrit'.format(path, len(commits)))
    changes = []
    change_ids = [commit['change-id'] for commit in commits]
    by_changeid = {commit['change-id']: commit for commit in commits}
    # fetch info for each commit from gerrit
    # note that this is newest to oldest, but we want to return oldest to newest (for picklist order)
    for change in gerrit.get_changes_from_ids(change_ids, branch, project):
        commit = by_changeid[change['change_id']]
        if change['_number'] == -1:
            obj = (path, -1, False, commit['subject'])
        else:
            # assume all non-open changes need to be force-picked.
            obj = (path, change['_number'], change['status'] != 'NEW', commit['subject'])
        changes.append(obj)
    # reverse changes list to return oldest to newest
    return changes[::-1]

def generate_picklist(args, ok_repos):
    ''' create a picklist '''
    # get paths to operate on
    # for each path, check if modified (y => process)
    global gerrit, manifest
    gerrit = Gerrit()
    manifest = RepoManifest()
    if not ok_repos:
        repos = manifest.get_project_paths()
    else:
        repos = ok_repos.intersection(manifest.get_project_paths())
        bad = ok_repos - repos
        if len(bad) > 0:
            print('These projects do not exist in your repo manifest: {}'.format(' '.join(sorted(bad))), file=sys.stderr)
            sys.exit(1)

    # TODO: don't try get changes for projects that aren't on lineage gerrit (or, i guess, the supplied gerrit)
    picklist = Picklist()
    with Pool(args.jobs) as p:
        ch = p.imap(get_extra_changes, repos, 1)

        total = len(repos)
        cur = 0
        for grp in ch:
            print('Found changes in {}/{}'.format(cur, total), end='\r')
            for c in grp:
                picklist.add_change(*c)
            cur += 1

    for path in args.picklist:
        with open(path, mode='w') as f:
            print(picklist.generate_yaml(), file=f)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('picklist', nargs='+', help='picklist file[s] to read/output to.')
    parser.add_argument('-j', '--jobs', type=int, default=4, help='maximum number of repopick instances to spawn at a time. default 4.')
    parser.add_argument('-r', '--repo', action='append', help='only operate on specified repo[s].')
    app = parser.add_argument_group('Options for applying picklists')
    app.add_argument('-c', '--checkout-upstream', choices=['yes', 'hard', 'no'], default='no', help='checkout upstream before picking. will also git reset --hard if "hard" is selected.')
    gen = parser.add_argument_group('Options for creating picklists')
    gen.add_argument('-g', '--generate', action='store_true', help='generate a picklist from your current tree rather than applying one')
    args = parser.parse_args()

    if not gettop():
        print('Could not find root of your Android source tree. Please cd into it!', file=sys.stderr)
        sys.exit(2)

    if args.repo:
        ok_repos = set(args.repo)
    else:
        ok_repos = False

    if args.generate:
        generate_picklist(args, ok_repos)
    else:
        apply_picklist(args, ok_repos)
