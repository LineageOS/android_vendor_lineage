# Inherit device configuration for mango.
$(call inherit-product, device/semc/mango/device_mango.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_mango
PRODUCT_BRAND := SEMC
PRODUCT_DEVICE := mango
PRODUCT_MODEL := SK17i
PRODUCT_MANUFACTURER := Sony Ericsson
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=SK17i BUILD_ID=4.0.A.2.368 BUILD_DISPLAY_ID=4.0.A.2.368 BUILD_FINGERPRINT=SEMC/SK17i_1249-8062/SK17i:2.3.3/4.0.A.2.368/j_b_3w:user/release-keys PRIVATE_BUILD_DESC="SK17i-user 2.3.3 4.0.A.2.368 j_b_3w test-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_mango_defconfig

# Extra mango overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/mango

# Add the Torch app
PRODUCT_PACKAGES += Torch


# BCM FM radio
#$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-XperiaMiniPro-SK17i
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-XperiaMiniPro-SK17i
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-XperiaMiniPro-SK17i-KANG
    endif
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
