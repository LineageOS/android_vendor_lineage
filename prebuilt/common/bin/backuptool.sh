#!/sbin/sh
#
# Backup and restore addon /system files
#

export C=/tmp/backupdir
export S=/system
export V=10.2

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

# Proceed only if /system is the expected major and minor version
check_prereq() {
if ( ! grep -q "^ro.cm.version=$V.*" /system/build.prop ); then
  echo "Not backing up files from incompatible version: $V"
  return 0
fi
return 1
}

check_blacklist() {
  if [ -f /system/addon.d/blacklist ];then
      ## Discard any known bad backup scripts
      cd /$1/addon.d/
      for f in *sh; do
          s=$(md5sum $f | awk {'print $1'})
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
          s=$(md5sum $f | awk {'print $1'})
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
for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
  $script $1
done
}

case "$1" in
  backup)
    mkdir -p $C
    if check_prereq; then
        if check_whitelist system; then
            exit 127
        fi
    fi
    check_blacklist system
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
  ;;
  restore)
    if check_prereq; then
        if check_whitelist tmp; then
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
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
