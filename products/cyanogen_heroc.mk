# Inherit AOSP device configuration for passion.
#$(call inherit-product, device/htc/heroc/froyo_heroc.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_heroc
PRODUCT_BRAND := htc
PRODUCT_DEVICE := heroc
PRODUCT_MODEL := Hero CDMA
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF83 BUILD_DISPLAY_ID=FRF83 PRODUCT_NAME=passion BUILD_FINGERPRINT=/passion/passion/mahimahi:2.2/FRF83/42295:user/release-keys
PRIVATE_BUILD_DESC="passion-user 2.2 FRF83 42295 release-keys"

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-N1
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Heroc-test0
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/heroc/media/bootanimation.zip:system/media/bootanimation.zip\
    vendor/cyanogen/prebuilt/heroc/etc/apns-conf.xml:system/etc/apns-conf.xml \
    vendor/cyanogen/prebuilt/heroc/etc/gps.conf:system/etc/gps.conf 
