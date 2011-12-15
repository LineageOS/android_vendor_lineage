PRODUCT_BRAND ?= cyanogenmod

ifdef CM_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmodnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.google.clientidbase=android-google \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/cm/CHANGELOG.mkdn:system/etc/CHANGELOG-CM.txt

PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh

PRODUCT_COPY_FILES +=  \
    vendor/cm/proprietary/RomManager.apk:system/app/RomManager.apk \
    vendor/cm/proprietary/Term.apk:system/app/Term.apk \
    vendor/cm/proprietary/lib/armeabi/libjackpal-androidterm3.so:system/lib/libjackpal-androidterm3.so \
    vendor/cm/prebuilt/common/bootanimation.zip:system/media/bootanimation.zip
  	

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/base/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Required CM packages
PRODUCT_PACKAGES += \
    LatinIME \
    Superuser \
    Superuser.apk \
    su

# Optional CM packages
PRODUCT_PACKAGES += \
    VideoEditor \
    VoiceDialer \
    Basic \
    HoloSpiralWallpaper \
    MagicSmokeWallpapers \
    NoiseField \
    Galaxy4 \
    LiveWallpapers \
    LiveWallpapersPicker \
    VisualizationWallpapers \
    PhaseBeam

# Custom CM packages
PRODUCT_PACKAGES += \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf

PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/dictionaries

PRODUCT_VERSION_MAJOR = 9
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0-RC0

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_DISPLAY_ID=ITL41D

ifdef CM_NIGHTLY
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.modversion=CyanogenMod-$(PRODUCT_VERSION_MAJOR)-$(shell date +%m%d%Y)-NIGHTLY-$(PRODUCT_RELEASE_NAME)
else
    ifdef CM_RELEASE
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(PRODUCT_RELEASE_NAME)
    else
        PRODUCT_PROPERTY_OVERRIDES += \
            ro.modversion=CyanogenMod-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(PRODUCT_RELEASE_NAME)-KANG
    endif
endif
