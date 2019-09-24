#!/sbin/sh
#
# System mount script
#

system=$(mount | grep system | sed 's|.*on ||' | sed 's| type.*||')
system_device=${2}

if [ -d /mnt/system ]; then
  sys_mount="/mnt/system"
elif [ -d /system_root ]; then
  sys_mount="/system_root"
else
  sys_mount="/system"
fi;

case ${1} in
  check)
    if [ ! -z "$system" ]; then
      umount $system
    fi
  ;;
  backup)
    mount $system_device $sys_mount
    ./tmp/install/bin/backuptool.sh "backup" $sys_mount/system
    umount $sys_mount
  ;;
  restore)
    mount $system_device $sys_mount -t ext4
    ./tmp/install/bin/backuptool.sh "restore" $sys_mount/system
    umount $sys_mount
  ;;
esac
