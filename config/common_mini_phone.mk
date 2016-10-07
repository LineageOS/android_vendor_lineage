$(call inherit-product, vendor/cm/config/common_mini.mk)

# Required CM packages
PRODUCT_PACKAGES += \
    LatinIME

$(call inherit-product, vendor/cm/config/telephony.mk)
