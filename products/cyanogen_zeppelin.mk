# Inherit AOSP device configuration for zeppelin.
$(call inherit-product, device/motorola/zeppelin/zeppelin.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

$(call inherit-product vendor/cyanogen/products/bcm_fm_radio.mk)

$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_zeppelin
PRODUCT_BRAND := motorola
PRODUCT_DEVICE := zeppelin
PRODUCT_MODEL := CLIQ XT
PRODUCT_MANUFACTURER := Motorola

#
# Set ro.modversion
#
ifdef CYANOGEN_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-7-$(shell date +%m%d%Y)-NIGHTLY-CLIQXT
else
    ifdef CYANOGEN_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.0.2-RC0-CLIQXT
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-7.0.2-RC0-CLIQXT-KANG
    endif
endif

#PRODUCT_BUILD_PROP_OVERRIDES := BUILD_ID=FRG83D BUILD_DISPLAY_ID=GRH78 PRODUCT_NAME=zeppelin TARGET_DEVICE=zeppelin BUILD_FINGERPRINT=MOTO/zeppelin_tmo_us/zepp/zepp:2.1-update1/ERD79/2.1.54:user/ota-rel-keys,release-keys PRODUCT_BRAND=tmobile PRIVATE_BUILD_DESC="zeppelin-user 2.1-update1 ERD79 2.1.54 ota-rel-keys,release-keys" BUILD_NUMBER=75603 BUILD_UTC_DATE=1289367602 TARGET_BUILD_TYPE=user BUILD_VERSION_TAGS=release-keys USER=android-build
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=zeppelin TARGET_DEVICE=zeppelin BUILD_ID=GRH78 BUILD_DISPLAY_ID=GRH78C BUILD_FINGERPRINT=google/soju/crespo:2.3.1/GRH78/85442:user/release-keys PRIVATE_BUILD_DESC="soju-user 2.3.1 GRH78 85442 release-keys"

PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_COPY_FILES += \
    device/motorola/zeppelin/sysctl.conf:system/etc/sysctl.conf

PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/zeppelin

# Add the FM app
PRODUCT_PACKAGES += FM
