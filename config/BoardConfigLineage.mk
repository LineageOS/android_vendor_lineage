ifneq ($(TARGET_USES_KERNEL_PLATFORM),true)
include vendor/lineage/config/BoardConfigKernel.mk
endif

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/lineage/config/BoardConfigQcom.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
