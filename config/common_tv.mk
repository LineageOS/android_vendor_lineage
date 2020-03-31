# Inherit common Lineage stuff
$(call inherit-product, vendor/lineage/config/common.mk)

# Inherit Lineage atv device tree
$(call inherit-product, device/lineage/atv/lineage_atv.mk)

PRODUCT_PACKAGES += \
    AppDrawer \
    LineageCustomizer

DEVICE_PACKAGE_OVERLAYS += vendor/lineage/overlay/tv
