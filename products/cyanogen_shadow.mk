# Inherit AOSP device configuration for passion.
$(call inherit-product, device/motorola/shadow/shadow.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_shadow
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := shadow
PRODUCT_MODEL := DROIDX
PRODUCT_MANUFACTURER := Motorola

# Release name and versioning
PRODUCT_RELEASE_NAME := DROIDX
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

PRODUCT_BUILD_PROP_OVERRIDES := BUILD_ID=VZW PRODUCT_NAME=shadow_vzw TARGET_DEVICE=cdma_shadow BUILD_FINGERPRINT=verizon/shadow_vzw/cdma_shadow/shadow:2.2.1/VZW/23.340:user/ota-rel-keys,release-keys PRODUCT_BRAND=verizon PRIVATE_BUILD_DESC="cdma_shadow-user 2.2.1 VZW 2.3.340 ota-rel-keys,release-keys" BUILD_NUMBER=2.3.340 BUILD_UTC_DATE=1289194863 TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys USER=w30471

PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/shadow

# Add the Torch app
PRODUCT_PACKAGES += Torch
