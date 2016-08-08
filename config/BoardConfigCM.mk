# Charger
ifneq ($(WITH_CM_CHARGER),false)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.cm
endif
