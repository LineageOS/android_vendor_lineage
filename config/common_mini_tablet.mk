# Inherit telephony stuff first to enable/disable features
$(call inherit-product, vendor/lineage/config/telephony.mk)

# Inherit mini common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME
