#!/bin/bash -e

echo "- Generating vendor/lineage/prebuilt/generated/build-manifest.xml"
python3 .repo/repo/repo manifest -o - -r | grep -Ev "proprietary_${MANIFEST_EXCLUDES}" > vendor/lineage/prebuilt/generated/build-manifest.xml
