# Inherit mobile mini common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

$(call inherit-product, vendor/lineage/config/wifionly.mk)
