# Inherit device configuration for saga.
$(call inherit-product, device/htc/saga/saga.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_saga
PRODUCT_BRAND := htc_europe
PRODUCT_DEVICE := saga
PRODUCT_MODEL := HTC Desire S
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=htc_saga BUILD_ID=GRJ90 BUILD_FINGERPRINT=htc_europe/htc_saga/saga:2.3.5/GRJ90/156318.4:user/release-keys PRIVATE_BUILD_DESC="2.10.401.4 CL156318 release-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_saga_defconfig

# Extra saga overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/saga

# Add the Torch app
PRODUCT_PACKAGES += Torch

# Broadcom FM radio
$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

# Release name and versioning
PRODUCT_RELEASE_NAME := DesireS
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
