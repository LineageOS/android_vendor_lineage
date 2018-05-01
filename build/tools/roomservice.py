#!/usr/bin/env python
# Copyright (C) 2012-2013, The CyanogenMod Project
#           (C) 2017,      The LineageOS Project
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

from __future__ import print_function

import base64
import json
import netrc
import os
import re
import sys
try:
  # For python3
  import urllib.error
  import urllib.parse
  import urllib.request
except ImportError:
  # For python2
  import imp
  import urllib2
  import urlparse
  urllib = imp.new_module('urllib')
  urllib.error = urllib2
  urllib.parse = urlparse
  urllib.request = urllib2

from xml.etree import ElementTree

#
# The purpose of this script is to import repositories (in addition to the ones
# already specified in .repo/default.xml and .repo/manifests/snippets/cm.xml),
# in order to satisfy the needs of a build for the lunch combo given as argument ($1).
#
# There are 2 scenarios, differentiated by the value of the depsonly parameter ($2).
# The build/envsetup.sh will try to find a lineage.mk file, placed in a ${product} folder,
# anywhere in the device/ subfolders.
#
# (a) If it finds such a ${product}/lineage.mk file ("depsonly" is supplied as true):
#       - The device repository is already there. Just its dependencies need to be downloaded.
#         The "depsonly" parameter is supplied as "true".
#       - To the end of fetching repositories, it will collect them from the dependencies files
#         (lineage.dependencies and cm.dependencies) of the projects in roomservice.xml.
#         It will recursively search for more dependencies in the repositories it finds, and
#         populates roomservice.xml with all new findings.
#       - After this process is over, all new projects in roomservice.xml are force-synced.
#
# (b) If no such ${product}/lineage.mk file is to be found ("depsonly" is not supplied):
#       - The device repository is not there. The roomservice script has the additional task of
#         finding it. Therefore, the "if not depsonly" conditions present in the code below
#         should be taken as synonymous with "if device makefile isn't there".
#       - The device's repo_path and repo_name are looked up on github.com/LineageOS/Hudson,
#         in the roomservice-main-device-repos.json file.
#       - After the above step is over, case (b) de-generates into case (a) - depsonly, as the
#         device repository was found.
#
# In summary, case (a) can be considered a sub-case of (b).
#

product = sys.argv[1]

if len(sys.argv) > 2:
    depsonly = sys.argv[2]
else:
    depsonly = None

try:
    device = product[product.index("_") + 1:]
except:
    device = product

if not depsonly:
    print("Device %s not found. Attempting to retrieve device repository from LineageOS Github (http://github.com/LineageOS)." % device)

# Register the Github API authentication token
try:
    authtuple = netrc.netrc().authenticators("api.github.com")

    if authtuple:
        auth_string = ('%s:%s' % (authtuple[0], authtuple[2])).encode()
        githubauth = base64.encodestring(auth_string).decode().replace('\n', '')
    else:
        githubauth = None
except:
    githubauth = None

def add_auth(githubreq):
    if githubauth:
        githubreq.add_header("Authorization","Basic %s" % githubauth)

local_manifests = r'.repo/local_manifests'
if not os.path.exists(local_manifests): os.makedirs(local_manifests)

def exists_in_tree(lm, path):
    for child in lm.getchildren():
        if child.attrib['path'] == path:
            return True
    return False

# in-place prettyprint formatter
def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def get_default_revision():
    m = ElementTree.parse(".repo/manifest.xml")
    d = m.findall('default')[0]
    r = d.get('revision')
    return r.replace('refs/heads/', '').replace('refs/tags/', '')

def get_from_manifest(devicename):
    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if re.search("android_device_.*_%s$" % device, localpath.get("name")):
            return localpath.get("path")

    return None

def is_in_manifest(projectpath):
    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    # Search in main manifest, too
    try:
        lm = ElementTree.parse(".repo/manifest.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    # ... and don't forget the lineage snippet
    try:
        lm = ElementTree.parse(".repo/manifests/snippets/lineage.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    return False

def add_to_manifest(repositories, fallback_branch = None):
    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for repository in repositories:
        repo_name = repository['repository']
        repo_target = repository['target_path']
        print('Checking if %s is fetched from %s' % (repo_target, repo_name))
        if is_in_manifest(repo_target):
            print('LineageOS/%s already fetched to %s' % (repo_name, repo_target))
            continue

        print('Adding dependency: LineageOS/%s -> %s' % (repo_name, repo_target))
        project = ElementTree.Element("project", attrib = { "path": repo_target,
            "remote": "github", "name": "LineageOS/%s" % repo_name })

        if 'branch' in repository:
            project.set('revision',repository['branch'])
        elif fallback_branch:
            print("Using fallback branch %s for %s" % (fallback_branch, repo_name))
            project.set('revision', fallback_branch)
        else:
            print("Using default branch for %s" % repo_name)

        lm.append(project)

    indent(lm, 0)
    raw_xml = ElementTree.tostring(lm).decode()
    raw_xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + raw_xml

    f = open('.repo/local_manifests/roomservice.xml', 'w')
    f.write(raw_xml)
    f.close()

# Function takes repo_path as input argument and searches for the
# dependencies files inside (lineage.dependencies and cm.dependencies - legacy).
# It then constructs a collection of:
#   (1) syncable_repos:
#       these are present in lineage.dependencies but not in the set of 3 repo manifests
#       (default.xml, cm.xml, roomservice.xml).
#   (2) fetch_list:
#       same definition as above.
#   Difference between (1) and (2) is:
# First all items in fetch_list will be added to roomservice.xml, as soon as they are found in lineage.dependencies.
# Then, after the process of populating roomservice.xml is finished, syncable_repos will contain the set of all new repos
# from fetch_list. "repo sync --force-sync" will be performed on syncable_repos.
#
#   (3) verify_repos:
#       These are repos found in lineage.dependencies, that either weren't present in the 3 repo manifests,
#       or were present but are of the form "android_device_*_*".
#       At the end, the fetch_dependencies function is called recursively for all verify_repos.
#
# The other (minor) input argument is just passed to the add_to_manifest function.
#
def fetch_dependencies(repo_path, fallback_branch = None):
    print('Looking for dependencies in %s' % repo_path)
    dependencies_path = repo_path + '/lineage.dependencies'
    syncable_repos = []
    verify_repos = []

    if os.path.exists(dependencies_path):
        dependencies_file = open(dependencies_path, 'r')
        dependencies = json.loads(dependencies_file.read())
        fetch_list = []

        for dependency in dependencies:
            if not is_in_manifest(dependency['target_path']):
                fetch_list.append(dependency)
                syncable_repos.append(dependency['target_path'])
                verify_repos.append(dependency['target_path'])
            else:
                verify_repos.append(dependency['target_path'])

        dependencies_file.close()

        if len(fetch_list) > 0:
            print('Adding dependencies to manifest')
            add_to_manifest(fetch_list, fallback_branch)
    else:
        print('%s has no additional dependencies.' % repo_path)

    if len(syncable_repos) > 0:
        print('Syncing dependencies')
        os.system('repo sync --force-sync %s' % ' '.join(syncable_repos))

    for deprepo in verify_repos:
        fetch_dependencies(deprepo)

def has_branch(branches, revision):
    return revision in [branch['name'] for branch in branches]

if depsonly:
    # depsonly was set if the lineage.mk file was found. Therefore, the
    # device repository definitely exists, it's just a matter of finding it.
    #
    # Search local_manifests.xml for all projects that contain "android_device_"
    # and end in "_${device}". Function returns first such occurrence.
    repo_path = get_from_manifest(device)
    if repo_path:
        fetch_dependencies(repo_path)
    else:
        # This error typically means that although we know the device repo
        # should have been there (because depsonly == true), we weren't able
        # to find it (because the search in local_manifests.xml was too
        # restrictive). Or perhaps depsonly was triggered by a false positive
        # in build/envsetup.sh. Should definitely not end up here.
        print("Trying dependencies-only mode on a non-existing device tree?")

    sys.exit(0)

else:
    # Not depsonly => device repository isn't here => we need to find it.
    # At this point, the "repositories" array has already been populated with the Github search.
    #
    # What we're trying to do is find the damn device repository, so the code paths
    # (depsonly and not depsonly) can converge back, by calling fetch_dependencies.
    githubreq = urllib.request.Request("https://raw.githubusercontent.com/LineageOS/hudson/master/roomservice-main-device-repos.json")
    add_auth(githubreq)
    try:
        result = urllib.request.urlopen(githubreq)
        body = result.read().decode("utf-8")
        json_data = json.loads(body)
    except urllib.error.URLError as ex:
        print("Failed to search GitHub")
        print(ex)
        sys.exit(1)
    except ValueError as ex:
        print("Failed to parse returned data from GitHub")
        print(ex)
        sys.exit(1)

    try:
        repo_name = json_data[device]["repository"]
        repo_path = json_data[device]["target_path"]
    except KeyError as ex:
        print("Failed to find info about device %s in github.com/LineageOS/hudson!" % device)
        sys.exit(1)
    except ValueError as ex:
        print("Failed to parse repository and target_path data for device %s!" % device)
        print(ex)
        sys.exit(1)
    # repo_name and repo_path now contain the device's
    # repository and target_path as specified by Hudson

    print("Found repository: %s" % repo_name)

    # This is the default_revision of our repo manifest, not of the Github remote repository.
    default_revision = get_default_revision()
    print("Default revision: %s" % default_revision)

    # We have to check that the remote repository has any
    # branch or tag to match our default revision
    print("Checking branch info")
    githubreq = urllib.request.Request("https://api.github.com/repos/LineageOS/%s/branches" % repo_name)
    add_auth(githubreq)
    result = json.loads(urllib.request.urlopen(githubreq).read().decode())

    ## Try tags, too, since that's what releases use
    if not has_branch(result, default_revision):
        githubreq = urllib.request.Request("https://api.github.com/repos/LineageOS/%s/tags" % repo_name)
        add_auth(githubreq)
        result.extend (json.loads(urllib.request.urlopen(githubreq).read().decode()))

    fallback_branch = None
    if not has_branch(result, default_revision):
        if os.getenv('ROOMSERVICE_BRANCHES'):
            fallbacks = list(filter(bool, os.getenv('ROOMSERVICE_BRANCHES').split(' ')))
            for fallback in fallbacks:
                if has_branch(result, fallback):
                    print("Using fallback branch: %s" % fallback)
                    fallback_branch = fallback
                    break

        if not fallback_branch:
            print("Default revision %s not found in %s. Bailing." % (default_revision, repo_name))
            print("Branches found:")
            for branch in [branch['name'] for branch in result]:
                print(branch)
            print("Use the ROOMSERVICE_BRANCHES environment variable to specify a list of fallback branches.")
            sys.exit(1)

    # fallback_branch is None if default_revision exists on remote
    adding = { "repository": repo_name, "target_path": repo_path }
    add_to_manifest([adding], fallback_branch)

    print("Syncing repository to retrieve project.")
    os.system('repo sync --force-sync %s' % repo_path)
    print("Repository synced!")

    fetch_dependencies(repo_path, fallback_branch)
    print("Done")
    sys.exit(0)

print("Repository for %s not found in the LineageOS Github repository list. If this is in error, you may need to manually add it to your local_manifests/roomservice.xml." % device)
