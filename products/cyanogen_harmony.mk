$(call inherit-product, device/nvidia/harmony/device_harmony.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_harmony
PRODUCT_BRAND := nvidia
PRODUCT_DEVICE := harmony
PRODUCT_MODEL := GTablet
PRODUCT_MANUFACTURER := malata
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF91 BUILD_DISPLAY_ID=FRF91 PRODUCT_NAME=harmony BUILD_FINGERPRINT=Flextronics/harmony/harmony/:2.2/FRF91/hudson-20101122-122046-TnT_SVN_2967:user/test-keys PRODUCT_BRAND=Flextronics TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=test-keys PRIVATE_BUILD_DESC="harmony-user 2.2 FRF91 hudson-20101122-122046-TnT_SVN_2967 test-keys" PRODUCT_MODEL=UPC300-2.2 PRODUCT_MANUFACTURER=malata

# Extra overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/harmony

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Harmony
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.1.0-Beta4-Harmony
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
