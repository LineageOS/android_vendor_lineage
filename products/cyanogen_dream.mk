# Inherit AOSP device configuration for dream.
$(call inherit-product, device/htc/dream/full_dream.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_dream
PRODUCT_BRAND := google
PRODUCT_DEVICE := dream
PRODUCT_MODEL := Dream
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF83 BUILD_DISPLAY_ID=FRF83 PRODUCT_NAME=dream BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF83/42295:user/release-keys
PRIVATE_BUILD_DESC="dream-user 2.2 FRF83 42295 release-keys"

PRODUCT_SPECIFIC_DEFINES += TARGET_PRELINKER_MAP=$(TOP)/vendor/cyanogen/prelink-linux-arm-ds.map

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Dream
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Dream-test0
endif

#
# Copy dream specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/dream-sapphire/media/bootanimation.zip:system/media/bootanimation.zip

