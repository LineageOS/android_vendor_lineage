$(call inherit-product, vendor/lineage/config/common_mini.mk)

# Required CM packages
PRODUCT_PACKAGES += \
    LatinIME

$(call inherit-product, vendor/lineage/config/telephony.mk)
