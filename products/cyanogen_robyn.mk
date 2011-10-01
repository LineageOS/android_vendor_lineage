# Inherit device configuration for robyn.
$(call inherit-product, device/semc/robyn/device_robyn.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_robyn
PRODUCT_BRAND := SEMC
PRODUCT_DEVICE := robyn
PRODUCT_MODEL := E10i
PRODUCT_MANUFACTURER := Sony Ericsson
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_DEVICE=E10i PRODUCT_NAME=E10i BUILD_ID=3.0.1.A.0.145 BUILD_DISPLAY_ID=3.0.1.A.0.145 BUILD_FINGERPRINT=SEMC/LT15i_1247-1073/LT15i:2.3.3/3.0.1.A.0.145/bn_p:user/release-keys PRIVATE_BUILD_DESC="LT15i-user 2.3.3 3.0.1.A.0.145 bn_P test-keys"

# Add the Torch app
PRODUCT_PACKAGES += Torch

# Add LDPI assets, in addition to MDPI
PRODUCT_LOCALES += ldpi mdpi

# Extra overlay for LDPI
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/ldpi

# Ti FM radio
#$(call inherit-product, vendor/cyanogen/products/ti_fm_radio.mk)

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-X10Mini
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-X10Mini
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.1.0-X10Mini-KANG
    endif
endif

#
# Copy MDPI specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/ldpi/media/bootanimation.zip:system/media/bootanimation.zip
