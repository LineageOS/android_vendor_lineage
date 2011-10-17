# Inherit AOSP device configuration for galaxys2att.
$(call inherit-product, device/samsung/galaxys2att/full_galaxys2att.mk)

# Inherit some common cyanogenmod stuff.
$(call inherit-product, vendor/cyanogen/products/common_full.mk)

# Include GSM stuff
$(call inherit-product, vendor/cyanogen/products/gsm.mk)

#
# Setup device specific product configuration.
#
PRODUCT_NAME := cyanogen_galaxys2att
PRODUCT_BRAND := samsung
PRODUCT_DEVICE := galaxys2att
PRODUCT_MODEL := SGH-I777
PRODUCT_MANUFACTURER := samsung
PRODUCT_BUILD_PROP_OVERRIDES += PRODUCT_NAME=SGH-I777 BUILD_ID=GWK74 BUILD_FINGERPRINT=samsung/SGH-I777/SGH-I777:2.3.7/GINGERBREAD/UCKH7:user/release-keys PRIVATE_BUILD_DESC="SGH-I777-user 2.3.7 GINGERBREAD UCKH7 release-keys"

# Extra captivate overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/cyanogen/overlay/galaxys2att

# Add FM and Torch Apps
PRODUCT_PACKAGES += \
    Torch \
    FM

# Extra RIL settings
PRODUCT_PROPERTY_OVERRIDES += \
    ro.ril.enable.managed.roaming=1 \
    ro.ril.oem.nosim.ecclist=911,112,999,000,08,118,120,122,110,119,995 \
    ro.ril.emc.mode=2

# Add additional mounts
PRODUCT_PROPERTY_OVERRIDES += \
    ro.additionalmounts=/mnt/emmc;/mnt/usbdisk \
    ro.vold.switchablepair=/mnt/sdcard,/mnt/emmc

# Release name and versioning
PRODUCT_RELEASE_NAME := Galaxys2ATT
PRODUCT_VERSION_DEVICE_SPECIFIC :=
-include vendor/cyanogen/products/common_versions.mk

#
# Copy captivate specific prebuilt files
#
PRODUCT_COPY_FILES +=  \
    vendor/cyanogen/prebuilt/hdpi/media/bootanimation.zip:system/media/bootanimation.zip
