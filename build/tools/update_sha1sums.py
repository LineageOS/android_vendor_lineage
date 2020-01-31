#!/usr/bin/env python
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
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

from hashlib import sha1
import sys

device = ''
vendor = ''

with open('proprietary-files.txt', 'r') as f:
    lines = f.read().splitlines()
vendorPath = '../../../vendor/' + vendor + '/' + device + '/proprietary'
needSHA1 = False


def cleanup():
    for index, line in enumerate(lines):
        # Skip empty or commented lines
        if len(line) == 0 or line[0] == '#':
            continue

        # Drop SHA1 hash, if existing
        if '|' in line:
            line = line.split('|')[0]
            lines[index] = '%s' % (line)


def update():
    for index, line in enumerate(lines):
        # Skip empty lines
        if len(line) == 0:
            continue

        # Check if we need to set SHA1 hash for the next files
        if line[0] == '#':
            needSHA1 = (' - from' in line)
            continue

        if needSHA1:
            # Remove existing SHA1 hash
            line = line.split('|')[0]
            filePath = line.split(':')[1] if len(
                line.split(':')) == 2 else line

            if filePath[0] == '-':
                file = open('%s/%s' % (vendorPath, filePath[1:]), 'rb').read()
            else:
                file = open('%s/%s' % (vendorPath, filePath), 'rb').read()

            hash = sha1(file).hexdigest()
            lines[index] = '%s|%s' % (line, hash)


if len(sys.argv) == 2 and sys.argv[1] == '-c':
    cleanup()
else:
    update()

with open('proprietary-files.txt', 'w') as file:
    file.write('\n'.join(lines) + '\n')
