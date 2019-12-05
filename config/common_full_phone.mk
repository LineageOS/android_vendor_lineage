# Inherit full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME

# Recorder
PRODUCT_PACKAGES += \
    Recorder

$(call inherit-product, vendor/lineage/config/telephony.mk)
