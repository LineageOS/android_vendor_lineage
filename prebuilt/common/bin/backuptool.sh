#!/sbin/sh
#
# Backup and restore addon /system files
#

export C=/tmp/backupdir
export S=/system
export V=9

# Mount /system if it is not already mounted
mount_system() {
if [ ! -f "$S/build.prop" ]; then
  mount $S
fi
}

# Unmount /system unless it is already unmounted
umount_system() {
if [ -f "$S/build.prop" ]; then
  umount $S
fi
}

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  mkdir -p /tmp/addon.d/
  cp -a /system/addon.d/* /tmp/addon.d/
  chmod 755 /tmp/addon.d/*.sh
}

# Restore /system/addon.d in /tmp/addon.d
restore_addon_d() {
  cp -a /tmp/addon.d/* /system/addon.d/
  rm -rf /tmp/addon.d/
}

# Proceed only if /system is the expected major version
check_prereq() {
if ( ! grep -q "^ro.cm.version=$V.*" /system/build.prop ); then
  echo "Not backing up files from incompatible version."
  umount_system
  exit 127
fi
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage() {
for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
  $script $1
done
}

case "$1" in
  backup)
    mkdir -p $C
    mount_system
    check_prereq
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
    umount_system
  ;;
  restore)
    mount_system
    check_prereq
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    umount_system
    rm -rf $C
    sync
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
