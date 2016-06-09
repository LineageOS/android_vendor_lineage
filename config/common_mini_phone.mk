$(call inherit-product, vendor/cm/config/common_mini.mk)

# Required CM packages
PRODUCT_PACKAGES += \
    LatinIME

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/cm/prebuilt/common/bootanimation/320.zip:system/media/bootanimation.zip
endif

$(call inherit-product, vendor/cm/config/telephony.mk)
