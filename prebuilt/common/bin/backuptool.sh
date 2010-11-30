#!/sbin/sh
#
# Backup and restore proprietary Android system files
#

C=/tmp/backupdir
S=/system
V=CyanogenMod-6

PROCEED=1;

check_prereq() {
   if ( ! grep -q "^ro.modversion=.*$V.*" /system/build.prop );
   then
      echo "Not backing up files from incompatible version.";
      PROCEED=0;
   fi
}

check_installscript() {
   if [ -f "/tmp/.installscript" ];
   then
      echo "/tmp/.installscript found. Skipping backuptool."
      PROCEED=0;
   fi
}

get_files() {
    cat <<EOF
app/CarHomeGoogle.apk
app/CarHomeLauncher.apk
app/Facebook.apk
app/GenieWidget.apk
app/Gmail.apk
app/GoogleBackupTransport.apk
app/GoogleCalendarSyncAdapter.apk
app/GoogleContactsSyncAdapter.apk
app/GoogleFeedback.apk
app/GooglePartnerSetup.apk
app/GoogleQuickSearchBox.apk app/QuickSearchBox.apk
app/GoogleServicesFramework.apk
app/googlevoice.apk
app/HtcCopyright.apk
app/HtcEmailPolicy.apk
app/HtcSettings.apk
app/kickback.apk
app/LatinImeTutorial.apk
app/Maps.apk
app/MapsSapphire.apk
app/MarketUpdater.apk
app/MediaUploader.apk
app/NetworkLocation.apk
app/OneTimeInitializer.apk
app/PassionQuickOffice.apk
app/Quickoffice.apk
app/SetupWizard.apk app/Provision.apk
app/soundback.apk
app/Street.apk
app/Talk.apk
app/talkback.apk
app/Twitter.apk
app/Vending.apk
app/VoiceSearch.apk
app/YouTube.apk
etc/permissions/com.google.android.maps.xml
etc/permissions/features.xml
framework/com.google.android.maps.jar
lib/libspeech.so
lib/libvoicesearch.so
etc/hosts
etc/custom_backup_list.txt
EOF
}

get_custom_files() {
   local L
   if [ -f "$C/custom_backup_list.txt" ];
   then
      [ ! -f $C/fixed_custom_backup_list.txt ] && tr -d '\r' < $C/custom_backup_list.txt \
            > $C/fixed_custom_backup_list.txt
      L=`cat $C/fixed_custom_backup_list.txt`
      cat <<EOF
$L
EOF
   fi
}

backup_file() {
   if [ -e "$1" ];
   then
      if [ -n "$2" ];
      then
         echo "$2  $1" | md5sum -c -
         if [ $? -ne 0 ];
         then
            echo "MD5Sum check for $1 failed!";
            exit $?;
         fi
      fi
      
      local F=`basename $1`
      
      # dont backup any apps that have odex files, they are useless
      if ( echo $F | grep -q "\.apk$" ) && [ -e `echo $1 | sed -e 's/\.apk$/\.odex/'` ];
      then
         echo "Skipping odexed apk $1";
      else
         cp -p $1 $C/$F
      fi
   fi
}

restore_file() {
   local FILE=`basename $1`
   local DIR=`dirname $1`
   if [ -e "$C/$FILE" ];
   then
      if [ ! -d "$DIR" ];
      then
         mkdir -p $DIR;
      fi
      cp -p $C/$FILE $1;
      if [ -n "$2" ];
      then
         rm $2;
      fi
   fi
}

check_installscript;

case "$1" in
   backup)
      mount $S
      check_prereq;
      if [ $PROCEED -ne 0 ];
      then
         rm -rf $C
         mkdir -p $C
         for file_list in get_files get_custom_files; do
           $file_list | while read FILE REPLACEMENT; do
              backup_file $S/$FILE
           done
         done
      fi
      umount $S
   ;;
   restore)
      check_prereq;
      if [ $PROCEED -ne 0 ];
      then
         for file_list in get_files get_custom_files; do
           $file_list | while read FILE REPLACEMENT; do
              R=""
              [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
              restore_file $S/$FILE $R
           done
         done
         rm -rf $C
      fi
   ;;
   *)
      echo "Usage: $0 {backup|restore}"
      exit 1
esac

exit 0
