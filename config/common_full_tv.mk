# Inherit full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full.mk)

# AOSP Apps
PRODUCT_PACKAGES += \
    LeanbackIme

# Lineage Apps
PRODUCT_PACKAGES += \
    AppDrawer \
    LineageCustomizer

DEVICE_PACKAGE_OVERLAYS += vendor/lineage/overlay/tv
