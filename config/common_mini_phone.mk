# Inherit mini common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME \
    LineageNavigationBarNoHint

$(call inherit-product, vendor/lineage/config/telephony.mk)
