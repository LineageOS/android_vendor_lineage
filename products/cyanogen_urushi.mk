# Inherit device configuration for urushi.
$(call inherit-product, device/semc/urushi/device_urushi.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_urushi
PRODUCT_BRAND := SEMC
PRODUCT_DEVICE := urushi
PRODUCT_MODEL := ST18i
PRODUCT_MANUFACTURER := Sony Ericsson
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=ST18i BUILD_ID=4.0.A.2.368 BUILD_FINGERPRINT=SEMC/ST18i_1247-1061/ST18i:2.3.3/3.0.1.A.0.145/bn_P:user/release-keys PRIVATE_BUILD_DESC="ST18i-user 2.3.3 3.0.1.A.0.145 bn_P test-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_urushi_defconfig

# Extra urushi overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/urushi

# Add the Torch app
PRODUCT_PACKAGES += Torch


# BCM FM radio
#$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

# Release name and versioning
PRODUCT_RELEASE_NAME := XperiaRay-ST18i
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
