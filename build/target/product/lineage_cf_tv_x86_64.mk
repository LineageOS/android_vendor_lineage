# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, device/google/cuttlefish/vsoc_x86_64/tv/aosp_cf.mk)

include vendor/lineage/build/target/product/lineage_generic_tv_target.mk

TARGET_DISABLE_EPPE := true
TARGET_NO_KERNEL_OVERRIDE := true

# Overrides
PRODUCT_NAME := lineage_cf_tv_x86_64
PRODUCT_MODEL := LineageOS Cuttlefish TV built for x86_64
