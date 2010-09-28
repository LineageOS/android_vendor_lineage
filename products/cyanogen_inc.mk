$(call inherit-product, device/htc/inc/inc.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_inc
PRODUCT_BRAND := htc
PRODUCT_DEVICE := inc
PRODUCT_MODEL := Incredible
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF91 BUILD_DISPLAY_ID=FRG83 PRODUCT_NAME=inc BUILD_FINGERPRINT=verizon_wwe/inc/inc/inc:2.2/FRF91/231334:user/release-keys PRODUCT_BRAND=verizon_wwe TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys PRIVATE_BUILD_DESC="3.21.605.1 CL231334 release-keys" PRODUCT_MODEL=ADR6300 PRODUCT_MANUFACTURER=HTC

PRODUCT_PROPERTY_OVERRIDES += ro.product.version=3.21.605.1

# Extra Passion overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/inc

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Inc
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.2-Inc
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
