include vendor/lineage/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/lineage/config/BoardConfigQcom.mk
else ifneq (,$(filter exynos%, $(TARGET_SOC)))
include vendor/lineage/config/BoardConfigExynos.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
