$(call inherit-product, device/htc/inc/inc.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_inc
PRODUCT_BRAND := htc
PRODUCT_DEVICE := inc
PRODUCT_MODEL := Incredible
PRODUCT_MANUFACTURER := HTC

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-N1
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-N1-test0
endif

ifndef DEFAULT_LAUNCHER
    PRODUCT_PACKAGES += ADWLauncher
endif