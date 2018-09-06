#!/usr/bin/env python
#
# Copyright (C) 2018 The LineageOS Project
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

import sys

def main(argv):
    original_file = 'vendor/lineage/prebuilt/common/etc/apns-conf.xml'
    sprint_override_file = 'vendor/lineage/tools/sprint_apns.xml'
    sprint_apn_names = ["Sprint LTE internet", "Sprint EHRPD internet", "Sprint internet"]

    if len(argv) == 2:
        output_file_path = argv[1]
    else:
        raise ValueError("Wrong number of arguments %s" % len(argv))

    with open(original_file, 'r') as input_file:
        with open(output_file_path, 'w') as output_file:
            for line in input_file:
                writeOriginalLine = True
                for apn in sprint_apn_names:
                    if apn in line:
                        with open(sprint_override_file, 'r') as sprint_file:
                            for override_line in sprint_file:
                                if apn in override_line:
                                    output_file.write(override_line)
                                    writeOriginalLine = False
                if writeOriginalLine:
                    output_file.write(line)

if __name__ == '__main__':
    main(sys.argv)
