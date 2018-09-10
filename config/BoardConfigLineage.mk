# Charger
ifeq ($(WITH_LINEAGE_CHARGER),true)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
include vendor/lineage/config/BoardConfigQcom.mk
endif

TARGET_AUTO_KDIR := $(shell echo $(TARGET_DEVICE_DIR) | sed -e 's/^device/kernel/g')
TARGET_KERNEL_SOURCE ?= $(TARGET_AUTO_KDIR)
KERNEL_SRC := $(TARGET_KERNEL_SOURCE)

ifneq "$(wildcard $(KERNEL_SRC) )" ""
PRODUCT_SOONG_NAMESPACES += \
    $(KERNEL_SRC)
endif
