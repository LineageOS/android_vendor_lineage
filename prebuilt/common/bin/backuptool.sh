#!/sbin/sh
#
# Backup and restore addon /system files
#

export C=/tmp/backupdir
export SYSDEV="$(readlink -nf "$2")"
export SYSFS="$3"
export V=17.1

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
cp -f /tmp/install/bin/backuptool.functions /tmp

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  if [ -d $S/addon.d/ ]; then
    mkdir -p /tmp/addon.d/
    cp -a $S/addon.d/* /tmp/addon.d/
    chmod 755 /tmp/addon.d/*.sh
  fi
}

# Restore /system/addon.d from /tmp/addon.d
restore_addon_d() {
  if [ -d /tmp/addon.d/ ]; then
    mkdir -p $S/addon.d/
    cp -a /tmp/addon.d/* $S/addon.d/
    rm -rf /tmp/addon.d/
  fi
}

# Proceed only if /system is the expected major and minor version
check_prereq() {
# If there is no build.prop file the partition is probably empty.
if [ ! -r $S/build.prop ]; then
    return 0
fi
if ! grep -q "^ro.lineage.version=$V.*" $S/build.prop; then
  echo "Not backing up files from incompatible version: $V"
  return 0
fi
return 1
}

check_blacklist() {
  if [ -f $S/addon.d/blacklist -a -d /$1/addon.d/ ]; then
      ## Discard any known bad backup scripts
      for f in /$1/addon.d/*sh; do
          [ -f $f ] || continue
          s=$(md5sum $f | cut -c-32)
          grep -q $s $S/addon.d/blacklist && rm -f $f
      done
  fi
}

check_whitelist() {
  found=0
  if [ -f $S/addon.d/whitelist ];then
      ## forcefully keep any version-independent stuff
      cd /$1/addon.d/
      for f in *sh; do
          s=$(md5sum $f | cut -c-32)
          grep -q $s $S/addon.d/whitelist
          if [ $? -eq 0 ]; then
              found=1
          else
              rm -f $f
          fi
      done
  fi
  return $found
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage() {
if [ -d /tmp/addon.d/ ]; then
  for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
    $script $1
  done
fi
}

determine_system_mount() {
  if grep -q -e"^$SYSDEV" /proc/mounts; then
    umount $(grep -e"^$SYSDEV" /proc/mounts | cut -d" " -f2)
  fi

  if [ -d /mnt/system ]; then
    SYSMOUNT="/mnt/system"
  elif [ -d /system_root ]; then
    SYSMOUNT="/system_root"
  else
    SYSMOUNT="/system"
  fi

  export S=$SYSMOUNT/system
}

mount_system() {
  mount -t $SYSFS $SYSDEV $SYSMOUNT -o rw,discard
}

unmount_system() {
  umount $SYSMOUNT
}

determine_system_mount

case "$1" in
  backup)
    mount_system
    mkdir -p $C
    if check_prereq; then
        if check_whitelist $S; then
            unmount_system
            exit 127
        fi
    fi
    check_blacklist $S
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
    unmount_system
  ;;
  restore)
    mount_system
    if check_prereq; then
        if check_whitelist tmp; then
            unmount_system
            exit 127
        fi
    fi
    check_blacklist tmp
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    rm -rf $C
    sync
    unmount_system
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
