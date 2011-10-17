# Inherit AOSP device configuration.
$(call inherit-product, device/motorola/jordan/jordan.mk)

# Inherit common GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Extra jordan overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/jordan

# Add the Torch app
PRODUCT_PACKAGES += Torch

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_jordan
PRODUCT_BRAND := MOTO
PRODUCT_DEVICE := jordan
PRODUCT_MODEL := MB525
PRODUCT_MANUFACTURER := motorola
PRODUCT_SBF := 3.4.2-179-4
PRODUCT_SFX := JOREM_U3

# Release name and versioning
PRODUCT_RELEASE_NAME := Defy
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

UTC_DATE := $(shell date +%s)
DATE     := $(shell date +%Y%m%d)

PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_ID=GWK74 \
    PRODUCT_NAME=${PRODUCT_MODEL}_${PRODUCT_SFX} \
    TARGET_DEVICE=umts_jordan \
    BUILD_FINGERPRINT=MOTO/${PRODUCT_MODEL}_${PRODUCT_SFX}/umts_jordan/jordan:2.3.7/${PRODUCT_SBF}/${UTC_DATE}:user/release-keys \
    PRIVATE_BUILD_DESC="umts_jordan-user 2.3.7 ${PRODUCT_SFX}_${PRODUCT_SBF} ${UTC_DATE} release-keys" \
    BUILD_NUMBER=${DATE} \
    BUILD_VERSION_TAGS=release-keys \
    TARGET_BUILD_TYPE=user

#
# Copy jordan specific prebuilt files
#
PRODUCT_COPY_FILES += \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip


