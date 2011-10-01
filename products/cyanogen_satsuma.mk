# Inherit device configuration for satsuma.
$(call inherit-product, device/semc/satsuma/device_satsuma.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_satsuma
PRODUCT_BRAND := SEMC
PRODUCT_DEVICE := satsuma
PRODUCT_MODEL := ST17i
PRODUCT_MANUFACTURER := Sony Ericsson
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=ST17i BUILD_ID=4.0.1.A.0.284 BUILD_DISPLAY_ID=4.0.1.A.0.284 BUILD_FINGERPRINT=SEMC/ST17i_1255-0788/ST17i:2.3.4/4.0.1.A.0.284/4_733w:user/release-keys PRIVATE_BUILD_DESC="ST17i-user 2.3.4 4.0.1.A.0.284 4_733w test-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_satsuma_defconfig

# Extra satsuma overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/satsuma

# Add the Torch app
#PRODUCT_PACKAGES += Torch


# BCM FM radio
#$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-XperiaMini-ST15i
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-XperiaMini-ST15i
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-XperiaMini-ST15i-KANG
    endif
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
