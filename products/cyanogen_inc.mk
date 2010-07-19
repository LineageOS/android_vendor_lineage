$(call inherit-product, device/htc/inc/inc.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_inc
PRODUCT_BRAND := htc
PRODUCT_DEVICE := inc
PRODUCT_MODEL := Incredible
PRODUCT_MANUFACTURER := HTC
# Use N1's build prop to fool the market...?
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=ERE27 BUILD_DISPLAY_ID=ERE27 PRODUCT_NAME=inc BUILD_FINGERPRINT=verizon/inc/inc/inc:2.1-update1/ERE27/161494:user/release-keys TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys PRIVATE_BUILD_DESC="1.22.605.2 CL161494 release-keys"

# Extra Passion overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/passion

# Build Kernel
PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=device/htc/inc/kernel

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Inc
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.0.0-Inc-test1
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/passion/media/bootanimation.zip:system/media/bootanimation.zip
