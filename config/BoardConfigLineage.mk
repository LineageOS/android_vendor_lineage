# Charger
ifeq ($(WITH_LINEAGE_CHARGER),true)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif

# Set generic definitions
include vendor/lineage/build/core/definitions.mk

include vendor/lineage/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/lineage/config/BoardConfigQcom.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
