# Charger
ifneq ($(WITH_LINEAGE_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif

# Dexpreopt
ifeq ($(HOST_OS),linux)
  ifneq ($(TARGET_BUILD_VARIANT),eng)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
      WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY := true
    endif
  endif
endif
