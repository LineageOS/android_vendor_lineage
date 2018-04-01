#!/usr/bin/env python
#
# Copyright (C) 2013-15 The CyanogenMod Project
#           (C) 2017    The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Run repopick.py -h for a description of this utility.
#

from __future__ import print_function

import sys
import json
import os
import subprocess
import re
import argparse
import textwrap
from functools import cmp_to_key
from xml.etree import ElementTree

try:
    import requests
except ImportError:
    try:
        # For python3
        import urllib.error
        import urllib.request
    except ImportError:
        # For python2
        import imp
        import urllib2
        urllib = imp.new_module('urllib')
        urllib.error = urllib2
        urllib.request = urllib2


# Verifies whether pathA is a subdirectory (or the same) as pathB
def is_subdir(a, b):
    a = os.path.realpath(a) + '/'
    b = os.path.realpath(b) + '/'
    return b == a[:len(b)]


def fetch_query_via_ssh(remote_url, query):
    """Given a remote_url and a query, return the list of changes that fit it
       This function is slightly messy - the ssh api does not return data in the same structure as the HTTP REST API
       We have to get the data, then transform it to match what we're expecting from the HTTP RESET API"""
    if remote_url.count(':') == 2:
        (uri, userhost, port) = remote_url.split(':')
        userhost = userhost[2:]
    elif remote_url.count(':') == 1:
        (uri, userhost) = remote_url.split(':')
        userhost = userhost[2:]
        port = 29418
    else:
        raise Exception('Malformed URI: Expecting ssh://[user@]host[:port]')


    out = subprocess.check_output(['ssh', '-x', '-p{0}'.format(port), userhost, 'gerrit', 'query', '--format=JSON --patch-sets --current-patch-set', query])
    if not hasattr(out, 'encode'):
        out = out.decode()
    reviews = []
    for line in out.split('\n'):
        try:
            data = json.loads(line)
            # make our data look like the http rest api data
            review = {
                'branch': data['branch'],
                'change_id': data['id'],
                'current_revision': data['currentPatchSet']['revision'],
                'number': int(data['number']),
                'revisions': {patch_set['revision']: {
                    'number': int(patch_set['number']),
                    'fetch': {
                        'ssh': {
                            'ref': patch_set['ref'],
                            'url': 'ssh://{0}:{1}/{2}'.format(userhost, port, data['project'])
                        }
                    }
                } for patch_set in data['patchSets']},
                'subject': data['subject'],
                'project': data['project'],
                'status': data['status']
            }
            reviews.append(review)
        except:
            pass
    args.quiet or print('Found {0} reviews'.format(len(reviews)))
    return reviews


def fetch_query_via_http(remote_url, query):
    if "requests" in sys.modules:
        auth = None
        if os.path.isfile(os.getenv("HOME") + "/.gerritrc"):
            f = open(os.getenv("HOME") + "/.gerritrc", "r")
            for line in f:
                parts = line.rstrip().split("|")
                if parts[0] in remote_url:
                    auth = requests.auth.HTTPBasicAuth(username=parts[1], password=parts[2])
        statusCode = '-1'
        if auth:
            url = '{0}/a/changes/?q={1}&o=CURRENT_REVISION&o=ALL_REVISIONS&o=ALL_COMMITS'.format(remote_url, query)
            data = requests.get(url, auth=auth)
            statusCode = str(data.status_code)
        if statusCode != '200':
            #They didn't get good authorization or data, Let's try the old way
            url = '{0}/changes/?q={1}&o=CURRENT_REVISION&o=ALL_REVISIONS&o=ALL_COMMITS'.format(remote_url, query)
            data = requests.get(url)
        reviews = json.loads(data.text[5:])
    else:
        """Given a query, fetch the change numbers via http"""
        url = '{0}/changes/?q={1}&o=CURRENT_REVISION&o=ALL_REVISIONS&o=ALL_COMMITS'.format(remote_url, query)
        data = urllib.request.urlopen(url).read().decode('utf-8')
        reviews = json.loads(data[5:])

    for review in reviews:
        review['number'] = review.pop('_number')

    return reviews


def fetch_query(remote_url, query):
    """Wrapper for fetch_query_via_proto functions"""
    if remote_url[0:3] == 'ssh':
        return fetch_query_via_ssh(remote_url, query)
    elif remote_url[0:4] == 'http':
        return fetch_query_via_http(remote_url, query.replace(' ', '+'))
    else:
        raise Exception('Gerrit URL should be in the form http[s]://hostname/ or ssh://[user@]host[:port]')

if __name__ == '__main__':
    # Default to LineageOS Gerrit
    default_gerrit = 'https://review.lineageos.org'

    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description=textwrap.dedent('''\
        repopick.py is a utility to simplify the process of cherry picking
        patches from LineageOS's Gerrit instance (or any gerrit instance of your choosing)

        Given a list of change numbers, repopick will cd into the project path
        and cherry pick the latest patch available.

        With the --start-branch argument, the user can specify that a branch
        should be created before cherry picking. This is useful for
        cherry-picking many patches into a common branch which can be easily
        abandoned later (good for testing other's changes.)

        The --abandon-first argument, when used in conjunction with the
        --start-branch option, will cause repopick to abandon the specified
        branch in all repos first before performing any cherry picks.'''))
    parser.add_argument('change_number', nargs='*', help='change number to cherry pick.  Use {change number}/{patchset number} to get a specific revision.')
    parser.add_argument('-i', '--ignore-missing', action='store_true', help='do not error out if a patch applies to a missing directory')
    parser.add_argument('-s', '--start-branch', nargs=1, help='start the specified branch before cherry picking')
    parser.add_argument('-r', '--reset', action='store_true', help='reset to initial state (abort cherry-pick) if there is a conflict')
    parser.add_argument('-a', '--abandon-first', action='store_true', help='before cherry picking, abandon the branch specified in --start-branch')
    parser.add_argument('-b', '--auto-branch', action='store_true', help='shortcut to "--start-branch auto --abandon-first --ignore-missing"')
    parser.add_argument('-q', '--quiet', action='store_true', help='print as little as possible')
    parser.add_argument('-v', '--verbose', action='store_true', help='print extra information to aid in debug')
    parser.add_argument('-f', '--force', action='store_true', help='force cherry pick even if change is closed')
    parser.add_argument('-p', '--pull', action='store_true', help='execute pull instead of cherry-pick')
    parser.add_argument('-P', '--path', help='use the specified path for the change')
    parser.add_argument('-t', '--topic', help='pick all commits from a specified topic')
    parser.add_argument('-Q', '--query', help='pick all commits using the specified query')
    parser.add_argument('-g', '--gerrit', default=default_gerrit, help='Gerrit Instance to use. Form proto://[user@]host[:port]')
    parser.add_argument('-e', '--exclude', nargs=1, help='exclude a list of commit numbers separated by a ,')
    parser.add_argument('-c', '--check-picked', type=int, default=10, help='pass the amount of commits to check for already picked changes')
    args = parser.parse_args()
    if not args.start_branch and args.abandon_first:
        parser.error('if --abandon-first is set, you must also give the branch name with --start-branch')
    if args.auto_branch:
        args.abandon_first = True
        args.ignore_missing = True
        if not args.start_branch:
            args.start_branch = ['auto']
    if args.quiet and args.verbose:
        parser.error('--quiet and --verbose cannot be specified together')

    if (1 << bool(args.change_number) << bool(args.topic) << bool(args.query)) != 2:
        parser.error('One (and only one) of change_number, topic, and query are allowed')

    # Change current directory to the top of the tree
    if 'ANDROID_BUILD_TOP' in os.environ:
        top = os.environ['ANDROID_BUILD_TOP']

        if not is_subdir(os.getcwd(), top):
            sys.stderr.write('ERROR: You must run this tool from within $ANDROID_BUILD_TOP!\n')
            sys.exit(1)
        os.chdir(os.environ['ANDROID_BUILD_TOP'])

    # Sanity check that we are being run from the top level of the tree
    if not os.path.isdir('.repo'):
        sys.stderr.write('ERROR: No .repo directory found. Please run this from the top of your tree.\n')
        sys.exit(1)

    # If --abandon-first is given, abandon the branch before starting
    if args.abandon_first:
        # Determine if the branch already exists; skip the abandon if it does not
        plist = subprocess.check_output(['repo', 'info'])
        if not hasattr(plist, 'encode'):
            plist = plist.decode()
        needs_abandon = False
        for pline in plist.splitlines():
            matchObj = re.match(r'Local Branches.*\[(.*)\]', pline)
            if matchObj:
                local_branches = re.split('\s*,\s*', matchObj.group(1))
                if any(args.start_branch[0] in s for s in local_branches):
                    needs_abandon = True

        if needs_abandon:
            # Perform the abandon only if the branch already exists
            if not args.quiet:
                print('Abandoning branch: %s' % args.start_branch[0])
            subprocess.check_output(['repo', 'abandon', args.start_branch[0]])
            if not args.quiet:
                print('')

    # Get the master manifest from repo
    #   - convert project name and revision to a path
    project_name_to_data = {}
    manifest = subprocess.check_output(['repo', 'manifest'])
    xml_root = ElementTree.fromstring(manifest)
    projects = xml_root.findall('project')
    remotes = xml_root.findall('remote')
    default_revision = xml_root.findall('default')[0].get('revision')

    #dump project data into the a list of dicts with the following data:
    #{project: {path, revision}}

    for project in projects:
        name = project.get('name')
        path = project.get('path')
        revision = project.get('revision')
        if revision is None:
            for remote in remotes:
                if remote.get('name') == project.get('remote'):
                    revision = remote.get('revision')
            if revision is None:
                revision = default_revision

        if not name in project_name_to_data:
            project_name_to_data[name] = {}
        revision = revision.split('refs/heads/')[-1]
        project_name_to_data[name][revision] = path

    # get data on requested changes
    reviews = []
    change_numbers = []

    def cmp_reviews(review_a, review_b):
        current_a = review_a['current_revision']
        parents_a = [r['commit'] for r in review_a['revisions'][current_a]['commit']['parents']]
        current_b = review_b['current_revision']
        parents_b = [r['commit'] for r in review_b['revisions'][current_b]['commit']['parents']]
        if current_a in parents_b:
            return -1
        elif current_b in parents_a:
            return 1
        else:
            return cmp(review_a['number'], review_b['number'])

    if args.topic:
        reviews = fetch_query(args.gerrit, 'topic:{0}'.format(args.topic))
        change_numbers = [str(r['number']) for r in sorted(reviews, key=cmp_to_key(cmp_reviews))]
    if args.query:
        reviews = fetch_query(args.gerrit, args.query)
        change_numbers = [str(r['number']) for r in sorted(reviews, key=cmp_to_key(cmp_reviews))]
    if args.change_number:
        change_url_re = re.compile('https?://.+?/([0-9]+(?:/[0-9]+)?)/?')
        for c in args.change_number:
            change_number = change_url_re.findall(c)
            if change_number:
                change_numbers.extend(change_number)
            elif '-' in c:
                templist = c.split('-')
                for i in range(int(templist[0]), int(templist[1]) + 1):
                    change_numbers.append(str(i))
            else:
                change_numbers.append(c)
        reviews = fetch_query(args.gerrit, ' OR '.join('change:{0}'.format(x.split('/')[0]) for x in change_numbers))

    # make list of things to actually merge
    mergables = []

    # If --exclude is given, create the list of commits to ignore
    exclude = []
    if args.exclude:
        exclude = args.exclude[0].split(',')

    for change in change_numbers:
        patchset = None
        if '/' in change:
            (change, patchset) = change.split('/')

        if change in exclude:
            continue

        change = int(change)

        if patchset:
            patchset = int(patchset)

        review = next((x for x in reviews if x['number'] == change), None)
        if review is None:
            print('Change %d not found, skipping' % change)
            continue

        mergables.append({
            'subject': review['subject'],
            'project': review['project'],
            'branch': review['branch'],
            'change_id': review['change_id'],
            'change_number': review['number'],
            'status': review['status'],
            'fetch': None,
            'patchset': review['revisions'][review['current_revision']]['_number'],
        })

        mergables[-1]['fetch'] = review['revisions'][review['current_revision']]['fetch']
        mergables[-1]['id'] = change
        if patchset:
            try:
                mergables[-1]['fetch'] = [review['revisions'][x]['fetch'] for x in review['revisions'] if review['revisions'][x]['_number'] == patchset][0]
                mergables[-1]['id'] = '{0}/{1}'.format(change, patchset)
                mergables[-1]['patchset'] = patchset
            except (IndexError, ValueError):
                args.quiet or print('ERROR: The patch set {0}/{1} could not be found, using CURRENT_REVISION instead.'.format(change, patchset))

    for item in mergables:
        args.quiet or print('Applying change number {0}...'.format(item['id']))
        # Check if change is open and exit if it's not, unless -f is specified
        if (item['status'] != 'OPEN' and item['status'] != 'NEW' and item['status'] != 'DRAFT') and not args.query:
            if args.force:
                print('!! Force-picking a closed change !!\n')
            else:
                print('Change status is ' + item['status'] + '. Skipping the cherry pick.\nUse -f to force this pick.')
                continue

        # Convert the project name to a project path
        #   - check that the project path exists
        project_path = None

        if item['project'] in project_name_to_data and item['branch'] in project_name_to_data[item['project']]:
            project_path = project_name_to_data[item['project']][item['branch']]
        elif args.path:
            project_path = args.path
        elif args.ignore_missing:
            print('WARNING: Skipping {0} since there is no project directory for: {1}\n'.format(item['id'], item['project']))
            continue
        else:
            sys.stderr.write('ERROR: For {0}, could not determine the project path for project {1}\n'.format(item['id'], item['project']))
            sys.exit(1)

        # If --start-branch is given, create the branch (more than once per path is okay; repo ignores gracefully)
        if args.start_branch:
            subprocess.check_output(['repo', 'start', args.start_branch[0], project_path])

        # Determine the maximum commits to check already picked changes
        check_picked_count = args.check_picked
        branch_commits_count = int(subprocess.check_output(['git', 'rev-list', '--count', 'HEAD'], cwd=project_path))
        if branch_commits_count <= check_picked_count:
            check_picked_count = branch_commits_count - 1

        # Check if change is already picked to HEAD...HEAD~check_picked_count
        found_change = False
        for i in range(0, check_picked_count):
            if subprocess.call(['git', 'cat-file', '-e', 'HEAD~{0}'.format(i)], cwd=project_path, stderr=open(os.devnull, 'wb')):
                continue
            output = subprocess.check_output(['git', 'show', '-q', 'HEAD~{0}'.format(i)], cwd=project_path).split()
            if 'Change-Id:' in output:
                head_change_id = ''
                for j,t in enumerate(reversed(output)):
                    if t == 'Change-Id:':
                        head_change_id = output[len(output) - j]
                        break
                if head_change_id.strip() == item['change_id']:
                    print('Skipping {0} - already picked in {1} as HEAD~{2}'.format(item['id'], project_path, i))
                    found_change = True
                    break
        if found_change:
            continue

        # Print out some useful info
        if not args.quiet:
            print('--> Subject:       "{0}"'.format(item['subject'].encode('utf-8')))
            print('--> Project path:  {0}'.format(project_path))
            print('--> Change number: {0} (Patch Set {1})'.format(item['id'], item['patchset']))

        if 'anonymous http' in item['fetch']:
            method = 'anonymous http'
        else:
            method = 'ssh'

        # Try fetching from GitHub first if using default gerrit
        if args.gerrit == default_gerrit:
            if args.verbose:
                print('Trying to fetch the change from GitHub')

            if args.pull:
                cmd = ['git pull --no-edit github', item['fetch'][method]['ref']]
            else:
                cmd = ['git fetch github', item['fetch'][method]['ref']]
            if args.quiet:
                cmd.append('--quiet')
            else:
                print(cmd)
            result = subprocess.call([' '.join(cmd)], cwd=project_path, shell=True)
            FETCH_HEAD = '{0}/.git/FETCH_HEAD'.format(project_path)
            if result != 0 and os.stat(FETCH_HEAD).st_size != 0:
                print('ERROR: git command failed')
                sys.exit(result)
        # Check if it worked
        if args.gerrit != default_gerrit or os.stat(FETCH_HEAD).st_size == 0:
            # If not using the default gerrit or github failed, fetch from gerrit.
            if args.verbose:
                if args.gerrit == default_gerrit:
                    print('Fetching from GitHub didn\'t work, trying to fetch the change from Gerrit')
                else:
                    print('Fetching from {0}'.format(args.gerrit))

            if args.pull:
                cmd = ['git pull --no-edit', item['fetch'][method]['url'], item['fetch'][method]['ref']]
            else:
                cmd = ['git fetch', item['fetch'][method]['url'], item['fetch'][method]['ref']]
            if args.quiet:
                cmd.append('--quiet')
            else:
                print(cmd)
            result = subprocess.call([' '.join(cmd)], cwd=project_path, shell=True)
            if result != 0:
                print('ERROR: git command failed')
                sys.exit(result)
        # Perform the cherry-pick
        if not args.pull:
            cmd = ['git cherry-pick FETCH_HEAD']
            if args.quiet:
                cmd_out = open(os.devnull, 'wb')
            else:
                cmd_out = None
            result = subprocess.call(cmd, cwd=project_path, shell=True, stdout=cmd_out, stderr=cmd_out)
            if result != 0:
                if args.reset:
                    print('ERROR: git command failed, aborting cherry-pick')
                    cmd = ['git cherry-pick --abort']
                    subprocess.call(cmd, cwd=project_path, shell=True, stdout=cmd_out, stderr=cmd_out)
                else:
                    print('ERROR: git command failed')
                sys.exit(result)
        if not args.quiet:
            print('')
