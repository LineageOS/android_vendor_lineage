#!/system/bin/sh
#
# Backup and restore addon /system files
#

export S=/system
export C=/postinstall/tmp/backupdir
export V=19.1

export ADDOND_VERSION=3

# Partitions to mount for backup/restore in V3
export all_V3_partitions="vendor product system_ext"

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
mkdir -p /postinstall/tmp/
mountpoint /postinstall/tmp >/dev/null 2>&1 || mount -t tmpfs tmpfs /postinstall/tmp
cp -f /postinstall/system/bin/backuptool_ab.functions /postinstall/tmp/backuptool.functions

get_script_version() {
  version=$(grep "^# ADDOND_VERSION=" $1 | cut -d= -f2)
  [ -z "$version" ] && version=1
  echo $version
}

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  if [ -d /system/addon.d/ ]; then
    mkdir -p /postinstall/tmp/addon.d/
    cp -a /system/addon.d/* /postinstall/tmp/addon.d/

    # Discard any version 1 script, as it is not compatible with a/b
    for f in /postinstall/tmp/addon.d/*sh; do
      if [ $(get_script_version $f) = 1 ]; then
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

# Execute /system/addon.d/*.sh scripts with each $@ parameter
run_stages() {
if [ -d /postinstall/tmp/addon.d/ ]; then
  for script in $(find /postinstall/tmp/addon.d/ -name '*.sh' |sort -n); do
    # we have no /sbin/sh in android, only recovery
    # use /system/bin/sh here instead
    sed -i '0,/#!\/sbin\/sh/{s|#!/sbin/sh|#!/system/bin/sh|}' $script
    # we can't count on /tmp existing on an A/B device, so utilize /postinstall/tmp as tmpfs
    sed -i 's|. /tmp/backuptool.functions|. /postinstall/tmp/backuptool.functions|g' $script

    v=$(get_script_version $script)
    if [ $v -ge 3 ]; then
      mount_extra $all_V3_partitions
    else
      umount_extra $all_V3_partitions
    fi

    for stage in $@; do
      if [ $v -ge 3 ]; then
        $script $stage
      else
        ADDOND_VERSION=2 $script $stage
      fi
    done
  done
fi
}

#####################
### Mount helpers ###
#####################
get_block_for_mount_point() {
  grep -v "^#" /vendor/etc/fstab.$(getprop ro.boot.hardware) | grep "[[:blank:]]$1[[:blank:]]" | tail -n1 | tr -s [:blank:] ' ' | cut -d' ' -f1
}

find_block() {
  local name="$1"
  local fstab_entry=$(get_block_for_mount_point "/$name")
  # P-SAR hacks
  [ -z "$fstab_entry" ] && [ "$name" = "system" ] && fstab_entry=$(get_block_for_mount_point "/")
  [ -z "$fstab_entry" ] && [ "$name" = "system" ] && fstab_entry=$(get_block_for_mount_point "/system_root")

  local dev
  if [ "$DYNAMIC_PARTITIONS" = "true" ]; then
    if [ -n "$fstab_entry" ]; then
      dev="${BLK_PATH}/${fstab_entry}${SLOT_SUFFIX}"
    else
      dev="${BLK_PATH}/${name}${SLOT_SUFFIX}"
    fi
  else
    if [ -n "$fstab_entry" ]; then
      dev="${fstab_entry}${SLOT_SUFFIX}"
    else
      dev="${BLK_PATH}/${name}${SLOT_SUFFIX}"
    fi
  fi

  if [ -b "$dev" ]; then
    echo "$dev"
  fi
}

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
  for partition in $@; do
    mnt_point="/postinstall/$partition"
    mountpoint "$mnt_point" >/dev/null 2>&1 && continue
    [ -L "$mnt_point" ] && continue

    blk_dev=$(find_block "$partition")
    if [ -n "$blk_dev" ]; then
      [ "$DYNAMIC_PARTITIONS" = "true" ] && blockdev --setrw "$blk_dev"
      mount -o rw "$blk_dev" "$mnt_point"
    fi
  done
}

umount_extra() {
  for partition in $@; do
    # Careful with unmounting. If the update has a partition less than the current system,
    # /postinstall/$partition is a symlink to /system/$partition, which on the active slot
    # is a symlink to /$partition which is a mountpoint we would end up unmounting!
    [ ! -L "/postinstall/$partition" ] && umount -l "/postinstall/$partition" 2>/dev/null
  done
}

cleanup() {
  umount_extra $all_V3_partitions
  umount /postinstall/tmp
  rm -rf /postinstall/tmp
}

case "$1" in
  backup)
    if check_prereq; then
      mkdir -p $C
      preserve_addon_d
      run_stages pre-backup backup post-backup
    else
      cleanup
    fi
  ;;
  restore)
    if check_prereq; then
      run_stages pre-restore restore post-restore
      restore_addon_d
      cleanup
      sync
    else
      cleanup
    fi
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
