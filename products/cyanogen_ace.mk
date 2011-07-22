# Inherit device configuration for ace.
$(call inherit-product, device/htc/ace/ace.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_ace
PRODUCT_BRAND := htc_wwe
PRODUCT_DEVICE := ace
PRODUCT_MODEL := Desire HD
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=htc_ace BUILD_ID=GRI40 BUILD_DISPLAY_ID=GRJ90 BUILD_FINGERPRINT=htc_wwe/htc_ace/ace:2.3.3/GRI40/87995:user/release-keys PRIVATE_BUILD_DESC="2.50.405.2 CL87995 release-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_ace_defconfig

# Extra Ace overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/ace

# Add the Torch app
PRODUCT_PACKAGES += Torch

# Add AicBootFix for ace battery fix
PRODUCT_PACKAGES += AicBootFix

# Broadcom FM radio
$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-DesireHD
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-RC1-DesireHD
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-RC1-DesireHD-KANG
    endif
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
