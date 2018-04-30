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
# already specified in .repo/default.xml and .repo/manifests/snippets/lineage.xml),
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
#       - An attempt is made to use the Github Search API for repositories that have ${device} in
#         their name, for the LineageOS user.
#       - Of all repositories that are found via Github Search API, the first one taken to be
#         the true device repository is the first one that will match the (simplified)
#         regular expression "android_device_*_${device}".
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

repositories = []

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

if not depsonly:
    githubreq = urllib.request.Request("https://api.github.com/search/repositories?q=%s+user:LineageOS+in:name+fork:true" % device)
    add_auth(githubreq)
    try:
        result = json.loads(urllib.request.urlopen(githubreq).read().decode())
    except urllib.error.URLError:
        print("Failed to search GitHub")
        sys.exit()
    except ValueError:
        print("Failed to parse return data from GitHub")
        sys.exit()
    for res in result.get('items', []):
        repositories.append(res)

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

    sys.exit()

else:
    # Not depsonly => device repository isn't here => we need to find it.
    # At this point, the "repositories" array has already been populated with the Github search.
    #
    # What we're trying to do is find the device repository, so the code paths
    # (depsonly and not depsonly) can converge back, by calling fetch_dependencies.
    for repository in repositories:
        repo_name = repository['name']
        if re.match(r"^android_device_[^_]*_" + device + "$", repo_name):
            # We have a winner. Found on Github via searching by ${device} only!!
            print("Found repository: %s" % repository['name'])

            # We don't know what manufacturer we're looking at (the script was only given ${device}).
            # Assume that the manufacturer is what's left after stripping away
            # "android_device_" and "_${device}".
            manufacturer = repo_name.replace("android_device_", "").replace("_" + device, "")

            # This is the default_revision of our repo manifest, not of the Github remote repository.
            default_revision = get_default_revision()
            print("Default revision: %s" % default_revision)
            print("Checking branch info")
            githubreq = urllib.request.Request(repository['branches_url'].replace('{/branch}', ''))
            add_auth(githubreq)
            result = json.loads(urllib.request.urlopen(githubreq).read().decode())

            ## Try tags, too, since that's what releases use
            if not has_branch(result, default_revision):
                githubreq = urllib.request.Request(repository['tags_url'].replace('{/tag}', ''))
                add_auth(githubreq)
                result.extend (json.loads(urllib.request.urlopen(githubreq).read().decode()))

            # The script was also not told where to put the device repository that it was
            # supposed to find in non-depsonly mode.
            # Just assume its place is in device/${manufacturer}/${device}.
            repo_path = "device/%s/%s" % (manufacturer, device)
            adding = {'repository':repo_name,'target_path':repo_path}

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
                    sys.exit()

            add_to_manifest([adding], fallback_branch)

            print("Syncing repository to retrieve project.")
            os.system('repo sync --force-sync %s' % repo_path)
            print("Repository synced!")

            fetch_dependencies(repo_path, fallback_branch)
            print("Done")
            sys.exit()

print("Repository for %s not found in the LineageOS Github repository list. If this is in error, you may need to manually add it to your local_manifests/roomservice.xml." % device)
