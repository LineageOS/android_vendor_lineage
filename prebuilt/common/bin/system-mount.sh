#!/sbin/sh
#
# System mount script
#

system=$(mount | grep system | sed 's|.*on ||' | sed 's| type.*||')
system_device="/dev/block/bootdevice/by-name/system"

case ${1} in
  check)
    if [ ! -z "$system" ]; then
      umount $system
    fi
  ;;
  mount)
    if [ ! -d "/tmp/system_mount" ]; then
      mkdir /tmp/system_mount
    fi;
    mount $system_device /tmp/system_mount
  ;;
  unmount)
    umount /tmp/system_mount
  ;;
esac
