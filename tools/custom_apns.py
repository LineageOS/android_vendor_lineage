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
import xml.etree.ElementTree as etree
# Using lxml to preserve comments    
# import lxml.etree as etree

def queryAttribute(element, attribute):
    if attribute in element.attrib:
        return '[@'+attribute+'="'+element.attrib[attribute]+'"]'
    else:
        return ""

def main(argv):
    original_file = "vendor/lineage/prebuilt/common/etc/apns-conf.xml"
    apn_trees = []

    if len(argv) >= 3:
        output_file_path = argv[1]
        apn_trees.append(etree.parse(original_file))
        i = 2
        while i < len(argv):
            apn_trees.append(etree.parse(argv[i]))
            i += 1
    else:
        raise ValueError("Wrong number of arguments %s" % len(argv))

    apn_queries = []

    output_root = etree.Element("apns")
    output_root.set("version",apn_trees[0].getroot().attrib["version"])
    output_root.text = "\n  "

# Needs lxml lib to work    
#    for comment_data in apn_trees[0].xpath("preceding-sibling::comment()"):
#      output_root.addprevious(comment_data)

    while apn_trees:
        current_tree = apn_trees.pop(0)
        for apn_current in current_tree.findall("apn"):
            apn_query = "apn"
            apn_query += queryAttribute(apn_current,"carrier")
            apn_query += queryAttribute(apn_current,"mcc")
            apn_query += queryAttribute(apn_current,"mnc")
            if apn_query not in apn_queries:
                for overwrite_tree in apn_trees:
                    apn_overwrite = overwrite_tree.findall(apn_query)
                    if apn_overwrite:
                        apn_output = apn_overwrite[0]
                        break
                if not apn_overwrite:
                    apn_output = apn_current
                apn_output.tail = "\n  "
                output_root.append(apn_output)
                apn_queries.append(apn_query)

    if apn_output is not None:
        apn_output.tail = "\n"

    output_tree = etree.ElementTree(output_root)
    output_tree.write(output_file_path,encoding="UTF-8",xml_declaration=True)

if __name__ == "__main__":
    main(sys.argv)
