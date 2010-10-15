# Inherit device configuration for vision.
$(call inherit-product, device/htc/vision/vision.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_vision
PRODUCT_BRAND := tmobile
PRODUCT_DEVICE := vision
PRODUCT_MODEL := T-Mobile G2
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=htc_vision BUILD_ID=FRF91 BUILD_DISPLAY_ID=FRG83 BUILD_FINGERPRINT=tmobile/htc_vision/vision/vision:2.2/FRF91/255798:user/release-keys PRIVATE_BUILD_DESC="1.19.531.1 CL255798 release-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_vision_defconfig

# Include the Torch app
PRODUCT_PACKAGES += Torch

# Extra Vision overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/vision

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-vision
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.1.0-RC0-vision
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
