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

import os
import sys
from hashlib import sha1

class Updater:
    @staticmethod
    def setup(device='', vendor=''):
        global DEVICE, VENDOR, VENDOR_PATH
        DEVICE = device
        VENDOR = vendor
        VENDOR_PATH = os.path.join(
        *['..', '..', '..', 'vendor', VENDOR, DEVICE, 'proprietary'])

    def __init__(self, filename):
        self.filename = filename
        with open(self.filename, 'r') as f:
            self.lines = f.read().splitlines()

    def write(self):
        with open(self.filename, 'w') as f:
            f.write('\n'.join(self.lines) + '\n')

    def cleanup(self):
        for index, line in enumerate(self.lines):
            # Skip empty or commented lines
            if len(line) == 0 or line[0] == '#' or '|' not in line:
                continue

            # Drop SHA1 hash, if existing
            self.lines[index] = line.split('|')[0]

        self.write()

    def update(self):
        need_sha1 = False
        for index, line in enumerate(self.lines):
            # Skip empty lines
            if len(line) == 0:
                continue

            # Check if we need to set SHA1 hash for the next files
            if line[0] == '#':
                need_sha1 = (' - from' in line)
                continue

            if need_sha1:
                # Remove existing SHA1 hash
                line = line.split('|')[0]

                file_path = line.split(';')[0].split(':')[-1]
                if file_path[0] == '-':
                    file_path = file_path[1:]

                with open(os.path.join(VENDOR_PATH, file_path), 'rb') as f:
                    hash = sha1(f.read()).hexdigest()

                self.lines[index] = '{}|{}'.format(line, hash)

        self.write()

    @staticmethod
    def finish():
        for file in ['../../../device/' + VENDOR + '/' + DEVICE + '/proprietary-files.txt']:
            updater = Updater(file)
        if len(sys.argv) == 2 and sys.argv[1] == '-c':
            updater.cleanup()
        else:
            updater.update()
