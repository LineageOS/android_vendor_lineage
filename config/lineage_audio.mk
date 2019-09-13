#
# Lineage Audio Files
#

ALARM_PATH := vendor/lineage/prebuilt/common/media/audio/alarms
NOTIFICATION_PATH := vendor/lineage/prebuilt/common/media/audio/notifications
RINGTONE_PATH := vendor/lineage/prebuilt/common/media/audio/ringtones

# Alarms
PRODUCT_COPY_FILES += \
    $(ALARM_PATH)/CyanAlarm.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/CyanAlarm.ogg \
    $(ALARM_PATH)/NuclearLaunch.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/NuclearLaunch.ogg

# Notifications
PRODUCT_COPY_FILES += \
    $(NOTIFICATION_PATH)/CyanDoink.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/CyanDoink.ogg \
    $(NOTIFICATION_PATH)/CyanMail.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/CyanMail.ogg \
    $(NOTIFICATION_PATH)/CyanMessage.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/CyanMessage.ogg \
    $(NOTIFICATION_PATH)/Laser.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Laser.ogg \
    $(NOTIFICATION_PATH)/Naughty.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Naughty.ogg \
    $(NOTIFICATION_PATH)/Pong.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Pong.ogg \
    $(NOTIFICATION_PATH)/Rang.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Rang.ogg \
    $(NOTIFICATION_PATH)/Stone.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Stone.ogg

# Ringtones
PRODUCT_COPY_FILES += \
    $(RINGTONE_PATH)/Boxbeat.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Boxbeat.ogg \
    $(RINGTONE_PATH)/CyanTone.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CyanTone.ogg \
    $(RINGTONE_PATH)/Highscore.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Highscore.ogg \
    $(RINGTONE_PATH)/Lyon.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Lyon.ogg \
    $(RINGTONE_PATH)/Rockin.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Rockin.ogg \
    $(RINGTONE_PATH)/Sheep.mp3:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Sheep.mp3 \
    $(RINGTONE_PATH)/Yukaay.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Yukaay.ogg
