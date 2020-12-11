include vendor/lineage/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include build/make/target/board/BoardConfigPixelCommon.mk
include hardware/qcom-caf/common/BoardConfigQcom.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
