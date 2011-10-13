# Inherit device configuration for smultron.
$(call inherit-product, device/semc/smultron/device_smultron.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_smultron
PRODUCT_BRAND := SEMC
PRODUCT_DEVICE := smultron
PRODUCT_MODEL := ST15i
PRODUCT_MANUFACTURER := Sony Ericsson
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=ST15i BUILD_ID=4.0.A.2.368 BUILD_FINGERPRINT=SEMC/ST15i_1249-6227/ST15i:2.3.3/4.0.A.2.368/j_b_3w:user/release-keys PRIVATE_BUILD_DESC="ST15i-user 2.3.3 4.0.A.2.368 j_b_3w test-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_smultron_defconfig

# Extra smultron overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/smultron

# Add the Torch app
#PRODUCT_PACKAGES += Torch


# BCM FM radio
#$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

# Release name and versioning
PRODUCT_RELEASE_NAME := XperiaMini-ST15i
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
