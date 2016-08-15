#!/usr/bin/env python
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
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

device=''
vendor=''

lines = [ line for line in open('proprietary-files.txt', 'r') ]
vendorPath = '../../../vendor/' + vendor + '/' + device + '/proprietary'
needSHA1 = False

for index, line in enumerate(lines):
    # Remove '\n' character
    line = line[:-1]

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

        if line[0] == '-':
            file = open('%s/%s' % (vendorPath, line[1:]), 'rb').read()
        else:
            file = open('%s/%s' % (vendorPath, line), 'rb').read()

        hash = sha1(file).hexdigest()
        lines[index] = '%s|%s\n' % (line, hash)

with open('proprietary-files.txt', 'w') as file:
    for line in lines:
        file.write(line)

    file.close()
