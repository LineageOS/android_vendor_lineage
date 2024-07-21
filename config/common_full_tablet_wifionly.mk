$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Inherit mobile full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)

# Settings
PRODUCT_PRODUCT_PROPERTIES += \
    persist.settings.large_screen_opt.enabled=true

$(call inherit-product, vendor/lineage/config/wifionly.mk)
