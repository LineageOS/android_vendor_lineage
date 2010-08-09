# Inherit AOSP device configuration for heroc.
$(call inherit-product, device/htc/heroc/heroc.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Inherit apns list from common 
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_heroc
PRODUCT_BRAND := sprint
PRODUCT_DEVICE := heroc
PRODUCT_MODEL := HERO200
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF91 BUILD_DISPLAY_ID=FRF91 PRODUCT_NAME=passion BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF91/43546:user/release-keys 
TARGET_BUILD_TYPE=userdebug BUILD_VERSION_TAGS=release-keys
PRIVATE_BUILD_DESC="heroc-user 2.2 FRF91 43546 release-keys"

# Use Prebuilt kernel from heroC device tree
PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=device/htc/heroc/kernel

# Extra overlay for Gallery3D orientation hack
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/dream_sapphire

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Heroc
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Heroc-RC0
endif

#
# Copy dream/sapphire specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/dream_sapphire/media/bootanimation.zip:system/media/bootanimation.zip
