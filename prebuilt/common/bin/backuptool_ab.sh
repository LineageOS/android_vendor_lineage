#!/system/bin/sh
#
# Backup and restore addon /system files
#

export S=/system
export C=/postinstall/tmp/backupdir
export V=18.1

export ADDOND_VERSION=3

# Partitions to mount for backup/restore in V3
export all_V3_partitions="vendor product system_ext odm oem"

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
mkdir -p /postinstall/tmp/
mountpoint /postinstall/tmp >/dev/null 2>&1 || mount -t tmpfs tmpfs /postinstall/tmp
cp -f /postinstall/system/bin/backuptool_ab.functions /postinstall/tmp/backuptool.functions

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  if [ -d /system/addon.d/ ]; then
    mkdir -p /postinstall/tmp/addon.d/
    cp -a /system/addon.d/* /postinstall/tmp/addon.d/

    # Discard any version 1 script, as it is not compatible with a/b
    for f in /postinstall/tmp/addon.d/*sh; do
      SCRIPT_VERSION=$(grep "^# ADDOND_VERSION=" $f | cut -d= -f2)
      [ -z "$SCRIPT_VERSION" ] && SCRIPT_VERSION=1
      if [ $SCRIPT_VERSION = 1 ]; then
        rm $f
      fi
    done

    chmod 755 /postinstall/tmp/addon.d/*.sh
  fi
}

# Restore /postinstall/system/addon.d from /postinstall/tmp/addon.d
restore_addon_d() {
  if [ -d /postinstall/tmp/addon.d/ ]; then
    mkdir -p /postinstall/system/addon.d/
    cp -a /postinstall/tmp/addon.d/* /postinstall/system/addon.d/
    rm -rf /postinstall/tmp/addon.d/
  fi
}

# Proceed only if /system is the expected major and minor version
check_prereq() {
# If there is no build.prop file the partition is probably empty.
if [ ! -r /system/build.prop ]; then
  echo "Backup/restore is not possible. Partition is probably empty"
  return 1
fi
if ! grep -q "^ro.lineage.version=$V.*" /system/build.prop; then
  echo "Backup/restore is not possible. Incompatible ROM version: $V"
  return 2
fi
return 0
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage() {
scripts_path="/postinstall/tmp/addon.d/"
if [ -d $scripts_path ]; then
  for script in $(find $scripts_path -name '*.sh' |sort -n); do
    # we have no /sbin/sh in android, only recovery
    # use /system/bin/sh here instead
    sed -i '0,/#!\/sbin\/sh/{s|#!/sbin/sh|#!/system/bin/sh|}' $script
    # we can't count on /tmp existing on an A/B device, so utilize /postinstall/tmp as tmpfs
    sed -i 's|. /tmp/backuptool.functions|. /postinstall/tmp/backuptool.functions|g' $script

    SCRIPT_VERSION=$(grep "^# ADDOND_VERSION=" $script | cut -d= -f2)
    [ -z "$SCRIPT_VERSION" ] && SCRIPT_VERSION=1
    if [ $SCRIPT_VERSION -ge 3 ]; then
      [ "$1" = "pre-restore" ] && mount_extra $all_V3_partitions
      ADDON_V3=true $script $1
      [ "$1" = "post-restore" ] && umount_extra $all_V3_partitions
    else
      umount_extra $all_V3_partitions
      $script $1
    fi
  done
fi
}

#####################
### Mount helpers ###
#####################
DYNAMIC_PARTITIONS=$(getprop ro.boot.dynamic_partitions)
if [ "$DYNAMIC_PARTITIONS" = "true" ]; then
    BLK_PATH="/dev/block/mapper"
else
    BLK_PATH=/dev/block/bootdevice/by-name
fi

CURRENTSLOT=$(getprop ro.boot.slot_suffix)
if [ ! -z "$CURRENTSLOT" ]; then
  if [ "$CURRENTSLOT" = "_a" ]; then
    # Opposite slot
    SLOT_SUFFIX="_b"
  else
    SLOT_SUFFIX="_a"
  fi
fi

mount_extra() {
  for partition in $1; do
    mnt_point="/postinstall/$partition"
    mountpoint "$mnt_point" >/dev/null 2>&1 && break

    blk_dev="${BLK_PATH}/${partition}${SLOT_SUFFIX}"
    if [ -e "$blk_dev" ]; then
      [ "$DYNAMIC_PARTITIONS" = "true" ] && block --setrw "$blk_dev"
      mount -o rw "$blk_dev" "$mnt_point"
    fi
  done
}

umount_extra() {
  for partition in $1; do
    umount -l "/postinstall/$partition"
  done
}

case "$1" in
  backup)
    if check_prereq; then
      mkdir -p $C
      preserve_addon_d
      run_stage pre-backup
      run_stage backup
      run_stage post-backup
    fi
  ;;
  restore)
    if check_prereq; then
      run_stage pre-restore
      run_stage restore
      run_stage post-restore
      restore_addon_d
      rm -rf $C
      umount /postinstall/tmp
      rm -rf /postinstall/tmp
      sync
    fi
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
