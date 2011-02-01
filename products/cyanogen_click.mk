# Inherit AOSP device configuration for click.
$(call inherit-product, device/htc/click/click.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

# Build kernel
PRODUCT_SPECIFIC_DEFINES += TARGET_PREBUILT_KERNEL=device/htc/click/kernel

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_click
PRODUCT_BRAND := htc_wwe
PRODUCT_DEVICE := click
PRODUCT_MODEL := HTC click
PRODUCT_MANUFACTURER := HTC
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=htc_click BUILD_ID=FRG83 BUILD_DISPLAY_ID=GRH78C BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2.1/FRG83/60505:user/release-keys PRIVATE_BUILD_DESC="passion-user 2.2.1 FRG83 60505 release-keys"
PRIVATE_BUILD_DESC="passion-user 2.2.1 FRG83 60505 release-keys"

# Extra Passion overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/ldpi

# Boot animation
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/ldpi/media/bootanimation.zip:system/media/bootanimation.zip

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-$(shell date +%m%d%Y)-NIGHTLY-click
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.0.0-RC0-click
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-RC0-click-KANG
    endif
endif