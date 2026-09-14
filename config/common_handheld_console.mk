# Inherit common mobile Lineage stuff
$(call inherit-product, vendor/lineage/config/common.mk)

$(call inherit-product, vendor/lineage/config/wifionly.mk)

# Include AOSP audio files
$(call inherit-product-if-exists, frameworks/base/data/sounds/AudioPackage14.mk)
include vendor/lineage/config/aosp_audio.mk

# Include GoogleSansFlex font
$(call inherit-product-if-exists, external/google-fonts/google-sans-flex/fonts.mk)

# Include Lineage audio files
include vendor/lineage/config/lineage_audio.mk

# Default notification/alarm sounds
PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Hassium.ogg

# Apps
PRODUCT_PACKAGES += \
    AvatarPicker \
    Backgrounds \
    LatinIME

ifneq ($(TARGET_EXCLUDES_AUDIOFX),true)
PRODUCT_PACKAGES += \
    AudioFX
endif

ifeq ($(PRODUCT_TYPE), go)
PRODUCT_PACKAGES += \
    Launcher3QuickStepGo

PRODUCT_DEXPREOPT_SPEED_APPS += \
    Launcher3QuickStepGo
else
PRODUCT_PACKAGES += \
    Launcher3QuickStep

PRODUCT_DEXPREOPT_SPEED_APPS += \
    Launcher3QuickStep
endif

PRODUCT_PACKAGES += \
    Launcher3Overlay

# Charger
PRODUCT_PACKAGES += \
    charger_res_images

ifneq ($(WITH_LINEAGE_CHARGER),false)
PRODUCT_PACKAGES += \
    lineage_charger_animation \
    lineage_charger_animation_vendor
endif

# Extra cmdline tools
PRODUCT_PACKAGES += \
    unrar \
    zstd

# Fonts
PRODUCT_PACKAGES += \
    fonts_customization.xml \
    FontGoogleSansFlexOverlay

# Legal
PRODUCT_PRODUCT_PROPERTIES += \
    ro.lineagelegal.url=https://lineageos.org/legal

# TextClassifier
PRODUCT_PACKAGES += \
    libtextclassifier_annotator_en_model \
    libtextclassifier_annotator_universal_model \
    libtextclassifier_actions_suggestions_universal_model \
    libtextclassifier_lang_id_model

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/textclassifier/actions_suggestions.universal.model \
    system/etc/textclassifier/lang_id.model \
    system/etc/textclassifier/textclassifier.en.model \
    system/etc/textclassifier/textclassifier.universal.model

# Themes
PRODUCT_PACKAGES += \
    LineageBlackTheme \
    ThemePicker \
    ThemesStub

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/lineage/overlay/dictionaries
