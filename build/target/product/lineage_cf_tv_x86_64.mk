# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

# Cuttlefish TV sets its own ATV client id (ro.oem.key1); config/common.mk must not set another
PRODUCT_ATV_CLIENTID_BASE := ATV00000024CUTTLEFISHEMU

# en_US first, like full_base.mk: Cuttlefish's languages_full.mk would make the en_XC pseudo-locale
# the default (its bidi marks blew up the device name past mDNS' limit and crashed system_server)
PRODUCT_LOCALES := en_US

$(call inherit-product, device/google/cuttlefish/vsoc_x86_64_only/tv/aosp_cf.mk)

include vendor/lineage/build/target/product/lineage_generic_tv_target.mk

TARGET_DISABLE_EPPE := true
TARGET_NO_KERNEL_OVERRIDE := true

# Overrides
PRODUCT_NAME := lineage_cf_tv_x86_64
PRODUCT_MODEL := LineageOS Cuttlefish TV built for x86_64
