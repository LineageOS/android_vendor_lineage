# Inherit AOSP device configuration for espresso.
$(call inherit-product, device/htc/espresso/espresso.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_espresso
PRODUCT_BRAND := htc
PRODUCT_DEVICE := espresso
PRODUCT_MODEL := myTouch 3G Slide
PRODUCT_MANUFACTURER := T-Mobile
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF91 BUILD_DISPLAY_ID=FRF91 PRODUCT_NAME=passion BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF91/43546:user/release-keys PRIVATE_BUILD_DESC="passion-user 2.2 FRF91 43546 release-keys"

PRODUCT_SPECIFIC_DEFINES += TARGET_PRELINKER_MAP=$(TOP)/vendor/cyanogen/prelink-linux-arm-espresso.map

# Build Kernel
PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=device/htc/espresso/kernel

# Include the Torch app
PRODUCT_PACKAGES += Torch libjni_flash

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Slide
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Slide-alpha0
endif

#
# Copy espresso specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/espresso/media/bootanimation.zip:system/media/bootanimation.zip
