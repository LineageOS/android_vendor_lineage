# Inherit device configuration for Droid2WE.
$(call inherit-product, device/motorola/droid2we/droid2we.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
#$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_droid2we
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := droid2we
PRODUCT_MODEL := DROID2 GLOBAL
PRODUCT_MANUFACTURER := Motorola
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=droid2we_vzw BUILD_ID=S273 BUILD_FINGERPRINT=verizon/droid2we_vzw/cdma_droid2we/droid2we:2.2/S273/2.4.330:user/ota-rel-keys,release-keys PRIVATE_BUILD_DESC="cdma_droid2we-user 2.2 S273 2.4.330 ota-rel-keys,release-keys" TARGET_DEVICE=cdma_droid2we PRODUCT_BRAND=verizon BUILD_NUMBER=2.4.330 BUILD_UTC_DATE=1287722464 TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys USER=xrpk47

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_droid2we_defconfig

# Extra Droid2WE overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/droid2we

# Add the Torch app
PRODUCT_PACKAGES += Torch

# Build GanOptimizer
#PRODUCT_PACKAGES += GanOptimizer

# Broadcom FM radio
#$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

# Release name and versioning
PRODUCT_RELEASE_NAME := DROID2WE
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy Droid2WE specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
