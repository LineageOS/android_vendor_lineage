$(call inherit-product, device/advent/vega/vega.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_vega
PRODUCT_BRAND := advent
PRODUCT_DEVICE := vega
PRODUCT_MODEL := Vega
PRODUCT_MANUFACTURER := Advent
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=Vega BUILD_ID=GRI40 BUILD_DISPLAY_ID=GRI40 BUILD_FINGERPRINT=google/passion/passion:2.3.3/GRI40/102588:user/release-keys PRIVATE_BUILD_DESC="passion-user 2.3.3 GRI40 102588 release-keys"

# Extra overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/vega

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-Vega
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.0.0-RC1-Vega
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.0.0-RC1-Vega-KANG
    endif
endif

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
