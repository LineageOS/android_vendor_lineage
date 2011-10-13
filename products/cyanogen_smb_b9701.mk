$(call inherit-product, device/malata/smb_b9701/smb_b9701.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_smb_b9701
PRODUCT_BRAND := nvidia
PRODUCT_DEVICE := smb_b9701
PRODUCT_MODEL := Zpad-T8
PRODUCT_MANUFACTURER := malata
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=smb_b9701 BUILD_ID=GRJ22 BUILD_FINGERPRINT=google/passion/passion:2.3.4/GRJ22/121341:user/release-keys PRIVATE_BUILD_DESC="passion-user 2.3.4 GRJ22 121341 release-keys"

# Extra overlay
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/cyanogen/overlay/tablet \
    vendor/cyanogen/overlay/smb_b9701

# Release name and versioning
PRODUCT_RELEASE_NAME := smb_b9701
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy passion specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/mdpi/media/bootanimation.zip:system/media/bootanimation.zip
