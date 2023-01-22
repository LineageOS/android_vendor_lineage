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
from xml.dom.minidom import parseString

def main(argv):
    reload(sys)
    sys.setdefaultencoding('utf8')
    original_file = 'vendor/lineage/prebuilt/common/etc/apns-conf.xml'

    if len(argv) == 3:
        output_file_path = argv[1]
        custom_override_file = argv[2]
    else:
        raise ValueError("Wrong number of arguments %s" % len(argv))

    custom_apn_names = set()
    with open(custom_override_file, 'r') as f:
        for line in f:
            xmltree = parseString(line)
            carrier = xmltree.getElementsByTagName('apn')[0].getAttribute('carrier')
            custom_apn_names.add('"' + carrier + '"')

    with open(original_file, 'r') as input_file:
        with open(output_file_path, 'w') as output_file:
            for line in input_file:
                found_custom_apns = set()
                for apn in custom_apn_names:
                    if apn in line:
                        with open(custom_override_file, 'r') as custom_file:
                            for override_line in custom_file:
                                if apn in override_line:
                                    output_file.write(override_line)
                                    found_custom_apns.add(apn)
                if found_custom_apns:
                    custom_apn_names -= found_custom_apns
                else:
                    if "</apns>" in line:
                        if custom_apn_names:
                            for apn in custom_apn_names:
                                with open(custom_override_file, 'r') as custom_file:
                                    for override_line in custom_file:
                                        if apn in override_line:
                                            output_file.write(override_line)
                    output_file.write(line)

if __name__ == '__main__':
    main(sys.argv)
