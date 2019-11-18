#!/usr/bin/env python3
import argparse
import os, os.path
import requests
import subprocess
import sys
import time
import yaml

from multiprocessing.pool import ThreadPool

TOP = None
def find_top():
    ''' cd into the root of the android repository, and return its path. '''
    global TOP
    if TOP is not None:
        return TOP
    while not os.path.exists('build/make/core/envsetup.mk'):
        os.chdir('..')
        if os.getcwd() == '/':
            TOP = False
            return False
    TOP = os.getcwd()
    return TOP

pick_counts = {}
def run_repopick(changes, path=None, extra_args=[]):
    ''' repopick the given changes to the given path. '''
    global pick_counts
    top = find_top()
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

def reset_repo(repo, hard=False):
    ''' reset a repo to the upstream HEAD '''
    proc = subprocess.run(['repo', 'info', repo], capture_output=True, text=True)
    if proc.returncode != 0:
        raise ValueError('repo info {} failed: {}'.format(repo, proc.returncode))

    rev = None
    for line in proc.stdout.split('\n'):
        if line.startswith('Current revision: '):
            rev = line.split()[2]
            break

    if rev is None:
        raise ValueError('failed to parse repo info output')

    curdir = os.getcwd()
    os.chdir(repo)
    if hard:
        ret = subprocess.run(['git', 'reset', '--hard'])

    cur_rev = subprocess.run(['git', 'rev-parse', 'HEAD'], capture_output=True, text=True).stdout.strip()
    if cur_rev == rev:
        os.chdir(curdir)
        print('{}: Already at upstream revision {}.'.format(repo, rev))
        return True

    print('{}: Checkout revision {}.'.format(repo, rev))
    ret = subprocess.run(['git', 'checkout', rev], capture_output=True)
    os.chdir(curdir)
    return ret.returncode == 0

def reset_all(repos, **kwargs):
    ''' reset all the given repos '''
    for repo in sorted(repos):
        reset_repo(repo, **kwargs)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('picklist', nargs='+', help='picklist file[s] to use.')
    parser.add_argument('-c', '--checkout-upstream', choices=['yes', 'hard', 'no'], default='no', help='checkout upstream before picking. will also git reset --hard if "hard" is selected.')
    parser.add_argument('-r', '--repo', action='append', help='only pick changes for specified repo[s].')
    parser.add_argument('-j', '--jobs', type=int, default=4, help='maximum number of repopick instances to spawn at a time. default 4.')
    args = parser.parse_args()

    reset_repos = set(['_args'])

    if not find_top():
        print('Could not find root of your Android source tree. Please cd into it!', file=sys.stderr)
        sys.exit(2)

    if args.repo:
        ok_repos = set(args.repo)
    else:
        ok_repos = False
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
