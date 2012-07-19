PRODUCT_BRAND ?= cyanogenmod

ifneq ($(TARGET_BOOTANIMATION_NAME),)
    PRODUCT_COPY_FILES += \
        vendor/cm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

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

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/cm/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/cm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# Compcache/Zram support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.local.rc:system/etc/init.local.rc \
    vendor/cm/prebuilt/common/bin/compcache:system/bin/compcache \
    vendor/cm/prebuilt/common/bin/handle_compcache:system/bin/handle_compcache

# Nam configuration script
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/modelid_cfg.sh:system/bin/modelid_cfg.sh

PRODUCT_COPY_FILES +=  \
    vendor/cm/proprietary/RomManager.apk:system/app/RomManager.apk \
    vendor/cm/proprietary/Term.apk:system/app/Term.apk \
    vendor/cm/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so \
    vendor/cm/prebuilt/common/apps/Superuser.apk:system/app/Superuser.apk

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/cm/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/cm/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/mkshrc:system/etc/mkshrc

# T-Mobile theme engine
include vendor/cm/config/themes_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    Camera \
    Development \
    LatinIME \
    SpareParts \
    Superuser \
    Superuser.apk \
    su

# Optional CM packages
PRODUCT_PACKAGES += \
    VideoEditor \
    VoiceDialer \
    SoundRecorder \
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
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    CMWallpapers \
    Apollo

# Extra tools in CM
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh \

PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/common

PRODUCT_VERSION_MAJOR = 10
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0-RC0

# Set CM_BUILDTYPE
ifdef CM_NIGHTLY
    CM_BUILDTYPE := NIGHTLY
endif
ifdef CM_EXPERIMENTAL
    CM_BUILDTYPE := EXPERIMENTAL
endif
ifdef CM_RELEASE
    CM_BUILDTYPE := RELEASE
endif

ifdef CM_BUILDTYPE
    ifdef CM_EXTRAVERSION
        # Force build type to EXPERIMENTAL
        CM_BUILDTYPE := EXPERIMENTAL
        # Add leading dash to CM_EXTRAVERSION
        CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
    endif
else
    # If CM_BUILDTYPE is not defined, set to UNOFFICIAL
    CM_BUILDTYPE := UNOFFICIAL
    CM_EXTRAVERSION :=
endif

ifdef CM_RELEASE
    CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CM_BUILD)
else
    CM_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(CM_BUILDTYPE)-$(CM_BUILD)$(CM_EXTRAVERSION)
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.version=$(CM_VERSION) \
  ro.modversion=$(CM_VERSION)
