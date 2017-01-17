#!/system/bin/sh
#
# LineageOS A/B OTA Postinstall Script
#

# Mount without a context and perform backuptool operations
/postinstall/system/bin/backuptool_ab.sh backup
/postinstall/system/bin/backuptool_ab.sh restore

sync

exit 0
