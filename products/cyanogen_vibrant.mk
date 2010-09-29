# Inherit device configuration for Vibrant.
$(call inherit-product, device/samsung/vibrant/full_vibrant.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_vibrant
PRODUCT_BRAND := Samsung
PRODUCT_DEVICE := SGH-T959
PRODUCT_MODEL := SGH-T959
PRODUCT_MANUFACTURER := Samsung
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=SGH-T959 BUILD_ID=FRG83 BUILD_DISPLAY_ID=FRG83 BUILD_FINGERPRINT=google/passion/passion/mahimahi:2.2.1/FRG83/60505:user/release-keys PRIVATE_BUILD_DESC="passion-user 2.2.1 FRG83 60505 release-keys"

# Extra Vibrant overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/vibrant

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6-$(shell date +%m%d%Y)-NIGHTLY-Vibrant
else
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-6.1.0-RC0-Vibrant
endif

#
# Copy Vibrant specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
