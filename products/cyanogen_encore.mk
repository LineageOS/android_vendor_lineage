# Inherit AOSP device configuration for encore.
$(call inherit-product, device/bn/encore/encore.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_encore
PRODUCT_BRAND := bn
PRODUCT_DEVICE := encore
PRODUCT_MODEL := NookColor
PRODUCT_MANUFACTURER := bn
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=encore BUILD_ID=GRK39F BUILD_FINGERPRINT=google/passion/passion:2.3.6/GRK39F/189904:user/release-keys PRIVATE_BUILD_DESC="passion-user 2.3.6 GRK39F 189904 release-keys"

PRODUCT_PACKAGE_OVERLAYS += \
    vendor/cyanogen/overlay/tablet \
    vendor/cyanogen/overlay/encore

# Release name and versioning
PRODUCT_RELEASE_NAME := encore
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip

