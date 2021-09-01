#!/usr/bin/python3

from argparse import ArgumentParser

TARGET_LEVEL_START = 5

VINTF_COMPATIBILITY_MATRIX_TEMPLATE = \
"""\
vintf_compatibility_matrix {{
    name: "framework_compatibility_matrix.lineage.{version}.xml",
    stem: "compatibility_matrix.lineage.{version}.xml",
    srcs: [
        "compatibility_matrix.lineage.base.xml",
        "compatibility_matrix.lineage.{version}.xml",
    ],
}}
"""

def main():
    parser = ArgumentParser()
    parser.add_argument("current_target_level", type=int, help="current target level")
    args = parser.parse_args()

    android_bp_fd = open("Android.bp", 'w')
    versions = range(TARGET_LEVEL_START, args.current_target_level + 1)
    for version in versions:
        open(f"compatibility_matrix.lineage.{version}.xml", 'w').write(
                f'<compatibility-matrix version="2.0" type="framework" level="{version}"/>\n')

    android_bp_fd.write("\n".join([VINTF_COMPATIBILITY_MATRIX_TEMPLATE.format(version=version)
                                   for version in versions]))

main()
