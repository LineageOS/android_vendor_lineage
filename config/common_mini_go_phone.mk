# Inherit mini common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME \
    TrebuchetQuickStepGo

PRODUCT_DEXPREOPT_SPEED_APPS += \
    TrebuchetQuickStepGo

$(call inherit-product, vendor/lineage/config/telephony.mk)
