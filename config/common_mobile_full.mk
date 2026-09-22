# Inherit common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile.mk)

PRODUCT_SIZE := full

# Include GoogleSansFlex font
$(call inherit-product-if-exists, external/google-fonts/google-sans-flex/fonts.mk)

# Apps
PRODUCT_PACKAGES += \
    Camelot \
    Etar \
    Profiles \
    Recorder \
    Seedvault \
    Twelve

ifneq ($(PRODUCT_NO_CAMERA),true)
PRODUCT_PACKAGES += \
    Aperture
else
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/lineage/overlay/no_camera
endif

ifneq ($(TARGET_EXCLUDES_AUDIOFX),true)
PRODUCT_PACKAGES += \
    AudioFX
endif

# Extra cmdline tools
PRODUCT_PACKAGES += \
    unrar \
    zstd

# Fonts
PRODUCT_PACKAGES += \
    fonts_customization.xml \
    FontGoogleSansFlexOverlay

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/lineage/overlay/dictionaries
