# Inherit AOSP device configuration for bravo.
$(call inherit-product, device/htc/bravo/full_bravo.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_bravo
PRODUCT_BRAND := htc_wwe
PRODUCT_DEVICE := bravo
PRODUCT_MODEL := HTC Desire
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF85B BUILD_DISPLAY_ID=FRF85B PRODUCT_NAME=passion BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF85B/42745:user/release-keys TARGET_BUILD_TYPE=userdebug
PRIVATE_BUILD_DESC="passion-user 2.2 FRF85B 42745 release-keys"

# Build Kernel
PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=device/htc/bravo-common/kernel

# Extra Passion overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/passion

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Bravo
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Bravo-test0
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/passion/media/bootanimation.zip:system/media/bootanimation.zip
