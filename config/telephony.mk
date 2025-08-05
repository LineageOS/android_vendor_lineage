# GMS
ifeq ($(WITH_GMS),true)
WITH_GMS_COMMS_SUITE := true
endif

# Sensitive Phone Numbers list
PRODUCT_PACKAGES += \
    sensitive_pn.xml

# World APN list
PRODUCT_PACKAGES += \
    apns-conf.xml

# Telephony packages
PRODUCT_PACKAGES += \
    messaging \
    Stk

ifneq ($(WITH_GMS),true)
# Default ringtone
PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.ringtone=Orion.ogg
endif

# Tethering - allow without requiring a provisioning app
# (for devices that check this)
PRODUCT_PRODUCT_PROPERTIES += \
    net.tethering.noprovisioning=true

# Disable mobile data by default
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.android.mobiledata=false
