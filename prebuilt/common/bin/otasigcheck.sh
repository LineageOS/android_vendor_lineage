#!/sbin/sh

# Validate that the incoming OTA is compatible with an already-installed
# system

grep -q "Command:.*\"--wipe\_data\"" /tmp/recovery.log
if [ $? -eq 0 ]; then
  echo "Data will be wiped after install; skipping signature check..."
  exit 0
fi

grep -q "Command:.*\"--headless\"" /tmp/recovery.log
if [ $? -eq 0 ]; then
  echo "Headless mode install; skipping signature check..."
  exit 0
fi

if [ -f "/data/system/packages.xml" -a -f "/tmp/releasekey" ]; then
  relkey=$(cat "/tmp/releasekey")
  OLDIFS="$IFS"
  IFS=""
  while read line; do
    params=${line# *<package *}
    if [ "$line" != "$params" ]; then
      kvp=${params%% *}
      params=${params#* }
      while [ "$kvp" != "$params" ]; do
        key=${kvp%%=*}
        val=${kvp#*=}
        vlen=$(( ${#val} - 2 ))
        val=${val:1:$vlen}
        if [ "$key" = "name" ]; then
          package="$val"
        fi
        kvp=${params%% *}
        params=${params#* }
      done
      continue
    fi
    params=${line# *<cert *}
    if [ "$line" != "$params" ]; then
      keyidx=""
      keyval=""
      kvp=${params%% *}
      params=${params#* }
      while [ "$kvp" != "$params" ]; do
        key=${kvp%%=*}
        val=${kvp#*=}
        vlen=$(( ${#val} - 2 ))
        val=${val:1:$vlen}
        if [ "$key" = "index" ]; then
          keyidx="$val"
        fi
        if [ "$key" = "key" ]; then
          keyval="$val"
        fi
        kvp=${params%% *}
        params=${params#* }
      done
      if [ -n "$keyidx" ]; then
        if [ "$package" = "com.android.htmlviewer" ]; then
          cert_idx="$keyidx"
        fi
      fi
      if [ -n "$keyval" ]; then
        eval "key_$keyidx=$keyval"
      fi
      continue
    fi
  done < "/data/system/packages.xml"
  IFS="$OLDIFS"

  # Tools missing? Err on the side of caution and exit cleanly
  if [ -z "$cert_idx" ]; then
    echo "Package cert index not found; skipping signature check..."
    exit 0
  fi

  varname="key_$cert_idx"
  eval "pkgkey=\$$varname"

  if [ "$pkgkey" != "$relkey" ]; then
     echo "You have an installed system that isn't signed with this build's key, aborting..."
     exit 124
  fi
fi

exit 0
