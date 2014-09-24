#!/sbin/sh

# Validate that the incoming OTA is compatible with an already-installed
# system

grep -q "Command:.*\"--wipe\_data\"" /tmp/recovery.log
if [ $? -eq 0 ]; then
  echo "Data will be wiped after install; skipping signature check..."
  exit 0
fi

if [ -f /data/system/packages.xml -a -f /tmp/releasekey ]; then
  relCert=$(grep -A3 'package name="com.android.htmlviewer"' /data/system/packages.xml  | grep "cert index" | head -n 1 | sed -e 's|.*"\([[:digit:]][[:digit:]]*\)".*|\1|g')

  grep "cert index=\"$relCert\"" /data/system/packages.xml | grep -q `cat /tmp/releasekey`
  if [ $? -ne 0 ]; then
     echo "You have an installed system that isn't signed with this build's key, aborting..."
     # Edify doesn't abort on non-zero executions, so let's trash the key and use sha1sum instead
     echo "INVALID" > /tmp/releasekey
     exit 1
  fi
fi

exit 0
