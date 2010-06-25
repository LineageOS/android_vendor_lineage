PRODUCT_NAME := cyanogen
PRODUCT_BRAND := cyanogen
PRODUCT_DEVICE := generic

TARGET_OTA_SCRIPT_MODE = edify

PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod

PRODUCT_PACKAGES += \
    CMParts

PRODUCT_COPY_FILES += \
    vendor/cyanogen/CHANGELOG:system/etc/CHANGELOG-CM.txt
