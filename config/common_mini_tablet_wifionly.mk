# Inherit common CM stuff
$(call inherit-product, vendor/cm/config/common_mini.mk)

# Required CM packages
PRODUCT_PACKAGES += \
    LatinIME
