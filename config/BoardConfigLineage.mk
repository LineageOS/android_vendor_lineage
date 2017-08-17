# Charger
ifneq ($(WITH_LINEAGE_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif

ifeq ($(BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE),)
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/data/cache
else
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/cache
endif
