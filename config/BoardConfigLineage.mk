# Charger
ifeq ($(WITH_LINEAGE_CHARGER),true)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif

prebuilt_build_tools_lineage := prebuilts/tools-lineage
prebuilt_build_tools_lineage_bin := $(prebuilt_build_tools_lineage)/$(HOST_PREBUILT_TAG)/bin

include vendor/lineage/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/lineage/config/BoardConfigQcom.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
