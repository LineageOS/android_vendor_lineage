#!/system/bin/sh
#
# Backup and restore addon /system files
#

export S=/system
export C=/postinstall/tmp/backupdir
export V=15.1

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
mkdir -p /postinstall/tmp/
cp -f /postinstall/system/bin/backuptool_ab.functions /postinstall/tmp/backuptool.functions

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  if [ -d /system/addon.d/ ]; then
    mkdir -p /postinstall/tmp/addon.d/
    cp -a /system/addon.d/* /postinstall/tmp/addon.d/
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
    return 0
fi

grep -q "^ro.lineage.version=$V.*" /system/etc/prop.default /system/build.prop && return 1

echo "Not backing up files from incompatible version: $V"
return 0
}

check_blacklist() {
  if [ -f /system/addon.d/blacklist -a -d /$1/addon.d/ ]; then
      ## Discard any known bad backup scripts
      cd /$1/addon.d/
      for f in *sh; do
          [ -f $f ] || continue
          s=$(md5sum $f | cut -c-32)
          grep -q $s /system/addon.d/blacklist && rm -f $f
      done
  fi
}

check_whitelist() {
  found=0
  if [ -f /system/addon.d/whitelist ];then
      ## forcefully keep any version-independent stuff
      cd /$1/addon.d/
      for f in *sh; do
          s=$(md5sum $f | cut -c-32)
          grep -q $s /system/addon.d/whitelist
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
    mkdir -p $C
    if check_prereq; then
        if check_whitelist postinstall/system; then
            exit 127
        fi
    fi
    check_blacklist postinstall/system
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
  ;;
  restore)
    if check_prereq; then
        if check_whitelist postinstall/tmp; then
            exit 127
        fi
    fi
    check_blacklist postinstall/tmp
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    rm -rf $C
    rm -rf /postinstall/tmp
    sync
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
