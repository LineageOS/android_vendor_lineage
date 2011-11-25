# Inherit common CM stuff
$(call inherit-product, vendor/cm/config/common.mk)

# Bring in all audio files
include frameworks/base/data/sounds/AllAudio.mk

# Default ringtone
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=Playa.ogg \
    ro.config.notification_sound=regulus.ogg \
    ro.config.alarm_alert=Alarm_Beep_03.ogg
