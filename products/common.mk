# Generic cyanogenmod product
PRODUCT_NAME := cyanogen
PRODUCT_BRAND := cyanogen
PRODUCT_DEVICE := generic

# Use edify for otapackage
PRODUCT_SPECIFIC_DEFINES += TARGET_OTA_SCRIPT_MODE=edify

# Add ROMManager build property
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod

# CyanogenMod specific product packages
PRODUCT_PACKAGES += \
    CMParts \
    Superuser

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/cyanogen/CHANGELOG:system/etc/CHANGELOG-CM.txt \
    vendor/cyanogen/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

# Allow the use of overlays
PRODUCT_PACKAGE_OVERLAYS := vendor/cyanogen/overlay

# Always run in insecure mode, enables root on user build variants
#ADDITIONAL_DEFAULT_PROPERTIES += ro.secure=0
