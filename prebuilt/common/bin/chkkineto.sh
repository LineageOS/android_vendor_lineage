#!/sbin/sh
#
# Remove KINETO if TMUS or GOOGLE Radio firmware not preset.
#

c=`/system/bin/getprop ro.carrier`
p=/system/app/MS-HTCVISION-KNT20-02.apk
r=y

if [ "$c" = "TMUS" ];
    then
       r=n
fi

if [ "$c" = "GOOGLE" ];
    then
       r=n
fi

if [ "$r" = "y" ];
    then
       if [ -f $p ];
          then
             rm -f /system/app/MS-HTCVISION-KNT20-02.apk
             rm -f /system/lib/libkineto.so
             rm -f /system/lib/libganril.so
             rm -f /system/lib/librilswitch.so
             sed 's/librilswitch.so/libhtc_ril.so/' /system/build.prop > /tmp/build.tmp
             sed '/rilswitch/d' /tmp/build.tmp > /system/build.prop
             chmod 644 /system/build.prop
             rm /tmp/build*
       fi
fi

exit 0
