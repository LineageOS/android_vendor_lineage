# Inherit AOSP device configuration for blade.
$(call inherit-product, device/samsung/cooper/device_cooper.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_cooper
PRODUCT_BRAND := samsung
PRODUCT_DEVICE := cooper
PRODUCT_MODEL := GT-S5830
PRODUCT_MANUFACTURER := Samsung
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=cooper BUILD_ID=GRWK74 BUILD_FINGERPRINT=samsung/GT-S5830/GT-S5830:2.3.4/GINGERBREAD/XXKPH:user/test-keys PRIVATE_BUILD_DESC="GT-S5830-user 2.3.4 GINGERBREAD XXKPH test-keys"

# Release name and versioning
PRODUCT_RELEASE_NAME := GalaxyAce
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy legend specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
