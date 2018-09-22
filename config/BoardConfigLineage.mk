# Charger
ifeq ($(WITH_LINEAGE_CHARGER),true)
    BOARD_HAL_STATIC_LIBRARIES := libhealthd.lineage
endif

include vendor/lineage/config/BoardConfigKernel.mk

include vendor/lineage/config/BoardConfigQcom.mk

include vendor/lineage/config/BoardConfigSoong.mk

PRODUCT_SOONG_NAMESPACES += $(PATHMAP_SOONG_NAMESPACES)
