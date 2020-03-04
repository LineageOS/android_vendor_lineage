#!/system/bin/sh
#
# Backup and restore addon /system files
#

export S=/system
export C=/postinstall/tmp/backupdir
export V=17.1

export ADDOND_VERSION=2

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
mkdir -p /postinstall/tmp/
cp -f /postinstall/system/bin/backuptool_ab.functions /postinstall/tmp/backuptool.functions

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  if [ -d /system/addon.d/ ]; then
    mkdir -p /postinstall/tmp/addon.d/
    cp -a /system/addon.d/* /postinstall/tmp/addon.d/

    # Discard any scripts that aren't at least our version level
    for f in /postinstall/tmp/addon.d/*sh; do
      SCRIPT_VERSION=$(grep "^# ADDOND_VERSION=" $f | cut -d= -f2)
      if [ -z "$SCRIPT_VERSION" ]; then
        SCRIPT_VERSION=1
      fi
      if [ $SCRIPT_VERSION -lt $ADDOND_VERSION ]; then
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
if [ -d /postinstall/tmp/addon.d/ ]; then
  for script in $(find /postinstall/tmp/addon.d/ -name '*.sh' |sort -n); do
    # we have no /sbin/sh in android, only recovery
    # use /system/bin/sh here instead
    sed -i '0,/#!\/sbin\/sh/{s|#!/sbin/sh|#!/system/bin/sh|}' $script
    # we can't count on /tmp existing on an A/B device, so utilize /postinstall/tmp
    # as a pseudo-/tmp dir
    sed -i 's|. /tmp/backuptool.functions|. /postinstall/tmp/backuptool.functions|g' $script
    $script $1
  done
fi
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
      rm -rf /postinstall/tmp
      sync
    fi
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
