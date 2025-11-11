$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Freeform window management
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.freeform_window_management.xml

# Settings
PRODUCT_PRODUCT_PROPERTIES += \
    persist.settings.large_screen_opt.enabled=true

# Tablet-specific overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/tablet
