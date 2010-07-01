# Inherit AOSP device configuration for sapphire.
$(call inherit-product, device/htc/sapphire/full_sapphire.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_sapphire
PRODUCT_BRAND := google
PRODUCT_DEVICE := sapphire
PRODUCT_MODEL := sapphire
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF83 BUILD_DISPLAY_ID=FRF83 PRODUCT_NAME=sapphire BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2/FRF83/42295:user/release-keys
PRIVATE_BUILD_DESC="sapphire-user 2.2 FRF83 42295 release-keys"

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Sapphire
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Sapphire-test0
endif

#
# Copy sapphire specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/dream-sapphire/media/bootanimation.zip:system/media/bootanimation.zip

