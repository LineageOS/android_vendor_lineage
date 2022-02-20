include vendor/lineage/config/BoardConfigKernel.mk

# Include vendor board platforms and utilities early
# enough so BoardConfigQcom can read from them.
include vendor/lineage/build/core/utils.mk
include vendor/lineage/build/core/vendor/qcom_boards.mk

ifneq ($(PRODUCT_MANUFACTURER), Google)
ifeq ($(call is-board-platform-in-list, $(QCOM_BOARD_PLATFORMS)),true)
include vendor/lineage/config/BoardConfigQcom.mk
endif
endif

include vendor/lineage/config/BoardConfigSoong.mk
