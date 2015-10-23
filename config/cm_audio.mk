#
# CyanogenMod Audio Files
#

ALARM_PATH := vendor/cm/prebuilt/common/media/audio/alarms
NOTIFICATION_PATH := vendor/cm/prebuilt/common/media/audio/notifications
RINGTONE_PATH := vendor/cm/prebuilt/common/media/audio/ringtones
UI_PATH := vendor/cm/prebuilt/common/media/audio/ui

# Alarms
PRODUCT_COPY_FILES += \
    $(ALARM_PATH)/CyanAlarm.ogg:system/media/audio/alarms/CyanAlarm.ogg \
    $(ALARM_PATH)/NuclearLaunch.ogg:system/media/audio/alarms/NuclearLaunch.ogg

# Notifications
PRODUCT_COPY_FILES += \
    $(NOTIFICATION_PATH)/CyanDoink.ogg:system/media/audio/notifications/CyanDoink.ogg \
    $(NOTIFICATION_PATH)/CyanMail.ogg:system/media/audio/notifications/CyanMail.ogg \
    $(NOTIFICATION_PATH)/CyanMessage.ogg:system/media/audio/notifications/CyanMessage.ogg \
    $(NOTIFICATION_PATH)/Laser.ogg:system/media/audio/notifications/Laser.ogg \
    $(NOTIFICATION_PATH)/Naughty.ogg:system/media/audio/notifications/Naughty.ogg \
    $(NOTIFICATION_PATH)/Pong.ogg:system/media/audio/notifications/Pong.ogg \
    $(NOTIFICATION_PATH)/Rang.ogg:system/media/audio/notifications/Rang.ogg \
    $(NOTIFICATION_PATH)/Stone.ogg:system/media/audio/notifications/Stone.ogg

# Ringtones
PRODUCT_COPY_FILES += \
    $(RINGTONE_PATH)/Boxbeat.ogg:system/media/audio/ringtones/Boxbeat.ogg \
    $(RINGTONE_PATH)/CyanTone.ogg:system/media/audio/ringtones/CyanTone.ogg \
    $(RINGTONE_PATH)/Highscore.ogg:system/media/audio/ringtones/Highscore.ogg \
    $(RINGTONE_PATH)/Lyon.ogg:system/media/audio/ringtones/Lyon.ogg \
    $(RINGTONE_PATH)/Rockin.ogg:system/media/audio/ringtones/Rockin.ogg \
    $(RINGTONE_PATH)/Sheep.mp3:system/media/audio/ringtones/Sheep.mp3 \
    $(RINGTONE_PATH)/Yukaay.mp3:system/media/audio/ringtones/Yukaay.mp3
