# Inherit device configuration for vivow.
$(call inherit-product, device/htc/vivow/vivow.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_vivow
PRODUCT_BRAND := verizon_wwe
PRODUCT_DEVICE := vivow
PRODUCT_MODEL := Incredible 2
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=htc_vivow BUILD_ID=GRI40 BUILD_DISPLAY_ID=GRJ90 BUILD_FINGERPRINT=verizon_wwe/htc_vivow/vivow:2.3.3/GRI40/81006:user/release-keys PRIVATE_BUILD_DESC="2.18.605.4 CL81006 release-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_vivow_defconfig

# Extra vivow overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/vivow

# Add the Torch app
PRODUCT_PACKAGES += Torch

# Add AicBootFix for vivow battery fix
PRODUCT_PACKAGES += AicBootFix

# Broadcom FM radio
$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-Inc2
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-Beta1-Inc2
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-RC1-Beta1-Inc2-KANG
    endif
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
