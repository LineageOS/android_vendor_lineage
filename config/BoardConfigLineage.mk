# Charger
ifneq ($(WITH_LINEAGE_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif
