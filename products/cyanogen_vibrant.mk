# Inherit device configuration for Vibrant.
$(call inherit-product, device/samsung/vibrant/full_vibrant.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_vibrant
PRODUCT_BRAND := google
PRODUCT_DEVICE := SGH-T959
PRODUCT_MODEL := Vibrant
PRODUCT_MANUFACTURER :=
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF91 BUILD_DISPLAY_ID=FRF91 PRODUCT_NAME=passion BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF91/43546:user/release-keys TARGET_BUILD_TYPE=userdebug BUILD_VERSION_TAGS=release-keys PRIVATE_BUILD_DESC="passion-user 2.2 FRF91 43546 release-keys"

# Extra Vibrant overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/vibrant

PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=device/vibrant/kernel

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_smdkc110_defconfig

# Enable Windows Media
WITH_WINDOWS_MEDIA := true

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Vibrant
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Vibrant-alpha0
endif

#
# Copy Vibrant specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
