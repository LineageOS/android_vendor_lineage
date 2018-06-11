#!/sbin/sh

if mount /system; then
    exit 0
fi

# Try to get the block from /etc/recovery.fstab
block=`cat /etc/recovery.fstab | cut -d '#' -f 1 | grep /system | grep -o '/dev/[^ ]*' | head -1`
if [ -n "$block" ] && mount $block /system; then
    exit 0
fi

# Modern devices use /system as root ("/")
system_as_root=`getprop ro.build.system_root_image`
if [ "$system_as_root" == "true" ]; then
  active_slot=`getprop ro.boot.slot_suffix`
  if [ ! -z "$active_slot" ]; then
    block=/dev/block/bootdevice/by-name/system$active_slot
  else
    block=/dev/block/bootdevice/by-name/system
  fi
  mkdir -p /system_root
  if mount -o rw $block /system_root && mount /system_root/system /system; then
    exit 0
  fi
fi

exit 1
