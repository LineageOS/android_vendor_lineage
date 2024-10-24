# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, device/google/cuttlefish/vsoc_x86_64/phone/aosp_cf.mk)

include vendor/lineage/build/target/product/lineage_generic_target.mk

TARGET_NO_KERNEL_OVERRIDE := true

# Overrides
PRODUCT_NAME := lineage_cf_phone_x86_64
PRODUCT_MODEL := LineageOS Cuttlefish phone built for x86_64
