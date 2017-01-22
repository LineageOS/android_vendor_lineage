#!/sbin/sh

if mount /system; then
    exit 0
fi

# Try to get the block from /etc/recovery.fstab
block=`cat /etc/recovery.fstab | cut -d '#' -f 1 | grep /system | grep -o '/dev/[^ ]*' | head -1`
if [ -n "$block" ] && mount $block /system; then
    exit 0
fi

exit 1
