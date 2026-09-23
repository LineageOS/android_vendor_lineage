# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

# build-manifest.xml
BUILD_BROKEN_SRC_DIR_RW_ALLOWLIST := $(abspath .repo/manifests.git)

# Recovery
BOARD_USES_FULL_RECOVERY_IMAGE ?= true

include vendor/lineage/config/BoardConfigKernel.mk

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
    include hardware/qcom-caf/common/BoardConfigQcom.mk
endif

include vendor/lineage/config/BoardConfigSoong.mk
