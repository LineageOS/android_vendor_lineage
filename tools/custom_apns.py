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

def is_apn(line):
    return line.lstrip().startswith('<apn ')

def main(argv):
    reload(sys)
    sys.setdefaultencoding('utf8')
    original_file = 'vendor/lineage/prebuilt/common/etc/apns-conf.xml'

    if len(argv) == 3:
        output_file_path = argv[1]
        custom_override_file = argv[2]
    else:
        raise ValueError("Wrong number of arguments %s" % len(argv))

    with open(custom_override_file, 'r') as f:
        custom_apn_lines = [line.strip() for line in f if is_apn(line)]

    with open(original_file, 'r') as input_file:
        with open(output_file_path, 'w') as output_file:
            for line in input_file:
                writeOriginalLine = not is_apn(line) or line.strip() not in custom_apn_lines
                if writeOriginalLine:
                    if "</apns>" in line:
                        with open(custom_override_file, 'r') as custom_file:
                            for override_line in custom_file:
                                if is_apn(override_line):
                                    output_file.write(override_line)
                    output_file.write(line)

if __name__ == '__main__':
    main(sys.argv)
