# Inherit AOSP device configuration for passion.
$(call inherit-product, device/motorola/droid2/droid2.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_droid2
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := droid2
PRODUCT_MODEL := DROID2
PRODUCT_MANUFACTURER := Motorola

# Release name and versioning
PRODUCT_RELEASE_NAME := DROID2
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

PRODUCT_BUILD_PROP_OVERRIDES := BUILD_ID=VZW PRODUCT_NAME=droid2_vzw TARGET_DEVICE=cdma_droid2 BUILD_FINGERPRINT=verizon/droid2_vzw/cdma_droid2/droid2:2.2/VZW/23.20:user/ota-rel-keys,release-keys PRODUCT_BRAND=verizon PRIVATE_BUILD_DESC="cdma_droid2-user 2.2 VZW 2.3.20 ota-rel-keys,release-keys" BUILD_NUMBER=2.3.20 BUILD_UTC_DATE=1284778494 TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys USER=dbretzm1

PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/droid2

# Add the Torch app
PRODUCT_PACKAGES += Torch
