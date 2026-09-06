# Inherit common Lineage stuff
$(call inherit-product, vendor/lineage/config/common.mk)

# Include GoogleSansFlex font
$(call inherit-product-if-exists, external/google-fonts/google-sans-flex/fonts.mk)

# Include AOSP audio files
$(call inherit-product-if-exists, frameworks/base/data/sounds/AudioTv.mk)

# Inherit Lineage atv device tree
$(call inherit-product, device/lineage/atv/lineage_atv.mk)

# AOSP packages
PRODUCT_PACKAGES += \
    LeanbackIME

# Lineage packages
PRODUCT_PACKAGES += \
    Catapult \
    LineageCustomizer

# Fonts
PRODUCT_PACKAGES += \
    fonts_customization.xml \
    FontGoogleSansFlexOverlay

PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/tv
