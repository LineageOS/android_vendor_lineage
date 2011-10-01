# Inherit device configuration for coconut.
$(call inherit-product, device/semc/coconut/device_coconut.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_coconut
PRODUCT_BRAND := SEMC
PRODUCT_DEVICE := coconut
PRODUCT_MODEL := WT19i
PRODUCT_MANUFACTURER := Sony Ericsson
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=WT19i BUILD_ID=4.0.2.A.0.42 BUILD_FINGERPRINT=SEMC/WT19i_1249-6227/WT19i:2.3.4/4.0.2.A.0.42/j_b_3w:user/release-keys PRIVATE_BUILD_DESC="WT19i-user 2.3.4 4.0.2.A.0.42 j_b_3w test-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_coconut_defconfig

# Extra coconut overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/coconut

# Add the Torch app
PRODUCT_PACKAGES += Torch

# BCM FM radio
#$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

# Release name and versioning
PRODUCT_RELEASE_NAME := LiveWithWalkman-WT19i
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
