$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Inherit telephony stuff first to enable/disable features
$(call inherit-product, vendor/lineage/config/telephony.mk)

# Inherit full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/lineage/overlay/dictionaries
