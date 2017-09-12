# Inherit full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full.mk)

PRODUCT_PACKAGES += TvSettings

DEVICE_PACKAGE_OVERLAYS += vendor/lineage/overlay/tv
