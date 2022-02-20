include vendor/lineage/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
# Include QCOM board platforms before the QCOM BoardConfig
# so we have SoCs listed for respective UM families.
include vendor/lineage/build/core/vendor/qcom_boards.mk
include vendor/lineage/config/BoardConfigQcom.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
