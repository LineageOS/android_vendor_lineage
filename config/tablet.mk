$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Settings
PRODUCT_PRODUCT_PROPERTIES += \
    persist.settings.large_screen_opt.enabled=true

# Tablet-specific overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/tablet
