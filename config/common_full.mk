# Inherit common CM stuff
$(call inherit-product, vendor/lineage/config/common.mk)

PRODUCT_SIZE := full

# Recorder
PRODUCT_PACKAGES += \
    Recorder
