#!/sbin/sh
#

# Remove KINETO on incorrect models.
#
# Valid:
# VISION   TMUS MODELID PC1010000
# MAHIMAHI TMUS MODELID PB9910000
# GLACIER  TMUS MODELID PD1510000
# Espresso TMUS MODELID PB6510000
#

kineto=/system/app/MS-HTCEMR-KNT20-02-A0-GB-02.apk
rm_kineto=y

cat /proc/cmdline|egrep -q '(PC1010000)|(PB9910000)|(PD1510000)|(PB6510000)'
if [ $? = 0 ];
    then
       rm_kineto=n
fi

if [ "$rm_kineto" = "y" ];
    then
       if [ -f $kineto ];
          then
             rm -f /system/app/MS-HTCEMR-KNT20-02-A0-GB-02.apk
             rm -f /system/lib/libkineto.so
             rm -f /system/lib/libganril.so
             rm -f /system/lib/librilswitch.so
             sed 's/librilswitch.so/libhtc_ril.so/' /system/build.prop > /tmp/build.tmp
             sed '/rilswitch/d' /tmp/build.tmp > /system/build.prop
             chmod 644 /system/build.prop
             rm /tmp/build*
       fi
fi

#
# Check for spade; if NAM model update DSP and GPS config
#
# NAM Models:
# DHD AT&T  MODELID PD9812000
# DHD TELUS MODELID PD9814000
#

cat /proc/cmdline | grep -q spade
if [ $? = 0 ];
   then 
cat /proc/cmdline | egrep -q '(PD9812000)|(PD9814000)'
      if [ $? = 0 ];
         then
            mv /system/etc/nam/*MCLK.txt /system/etc/soundimage/
            mv /system/etc/nam/CodecDSPID.txt /system/etc
            mv /system/etc/nam/gps.conf /system/etc
      fi
    rm -R /system/etc/nam
fi
