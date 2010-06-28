# Inherit AOSP device configuration for passion.
$(call inherit-product, device/motorola/sholes/sholes.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_sholes
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := sholes
PRODUCT_MODEL := Droid
PRODUCT_MANUFACTURER := Motorola

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

PRODUCT_BUILD_PROP_OVERRIDES := BUILD_ID=FRF57 BUILD_DISPLAY_ID="userdebug 2.2 FRF57 38829 test-keys" PRODUCT_NAME=voles TARGET_DEVICE=sholes BUILD_FINGERPRINT=verizon/voles/sholes/sholes:2.2/FRF57/38829:userdebug/test-keys PRODUCT_BRAND=verizon PRIVATE_BUILD_DESC="voles-userdebug 2.2 FRF57 38829 test-keys" BUILD_NUMBER=38829 BUILD_UTC_DATE=1274994078 TARGET_BUILD_TYPE=userdebug

PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/proprietary/RomManager.apk:system/app/RomManager.apk \
    vendor/cyanogen/prebuilt/passion/media/bootanimation.zip:system/media/bootanimation.zip