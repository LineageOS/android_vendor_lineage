# Inherit AOSP device configuration for speedy.
$(call inherit-product, device/htc/speedy/speedy.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_speedy
PRODUCT_BRAND := sprint
PRODUCT_DEVICE := speedy
PRODUCT_MODEL := PG06100
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_ID=FRF91 BUILD_DISPLAY_ID=GRH78C PRODUCT_NAME=htc_speedy BUILD_FINGERPRINT=sprint/htc_speedy/speedy/speedy:2.2/FRF91/291627:user/release-keys PRIVATE_BUILD_DESC="1.17.651.1 CL291627 release-keys"

# Build kernel
#PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_DIR=kernel-msm
#PRODUCT_SPECIFIC_DEFINES += TARGET_KERNEL_CONFIG=cyanogen_speedy_defconfig

# Extra Supersonic overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/speedy

# Add the Torch app
PRODUCT_PACKAGES += Torch

# Broadcom FM radio
$(call inherit-product, vendor/cyanogen/products/bcm_fm_radio.mk)

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-Speedy
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-Speedy
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-Speedy-KANG
    endif
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
