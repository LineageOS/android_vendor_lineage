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
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF85B BUILD_DISPLAY_ID=FRF85B PRODUCT_NAME=espresso BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF85B/42745:user/release-keys
PRIVATE_BUILD_DESC="espresso-user 2.2  42745 release-keys"

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

TARGET_PREBUILT_KERNEL := device/htc/espresso/kernel
