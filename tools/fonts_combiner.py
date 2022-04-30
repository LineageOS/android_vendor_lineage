#!/usr/bin/env python
import sys
import os
from xml.etree import ElementTree
import xml.dom.minidom as md


def combine(files):
    if not len(files) == 2:
        raise ValueError("Wrong number of arguments %s" % len(files))

    first = None
    for filename in files:
        data = ElementTree.parse(filename).getroot()
        if first is None:
            first = data
        else:
            first.extend(data)
    if first is not None:
        return (ElementTree.tostring(first)).decode()

def pretty(xml):
    dom = md.parse(xml)
    pretty_xml = dom.toprettyxml()
    pretty_xml = os.linesep.join([s for s in pretty_xml.splitlines()
                                  if s.strip()])
    with open(xml, "w") as file1:
        file1.writelines(pretty_xml)

if __name__ == "__main__":
    # First 2 args are files to combine.
    combined_xml = combine(sys.argv[1:3])
    # output file
    outfile = sys.argv[3]
    with open(outfile, "w") as f:
        f.writelines(combined_xml)
    pretty(outfile)
