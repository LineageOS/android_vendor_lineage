$(call inherit-product, $(SRC_TARGET_DIR)/product/large_screen_common.mk)

# Tablet-specific overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/tablet
