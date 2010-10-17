#!/sbin/sh
#
# Force /system dalvik-cache on /data instead of /cache if is not large enough
#

CACHESIZE=$(df -k /cache | tail -n1 | tr -s ' ' | cut -d ' ' -f2)
if [ $CACHESIZE -lt 60000 ]
then
  echo "dalvik.vm.dexopt-data-only=1" >> /system/build.prop
fi

exit 0
