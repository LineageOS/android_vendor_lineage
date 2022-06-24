# Copyright (C) 2022 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include vendor/lineage/build/target/product/lineage_generic_tv_target.mk

$(call inherit-product, device/google/atv/products/sdk_atv_armv7.mk)

TARGET_USES_64_BIT_BINDER := true
TARGET_NO_KERNEL_OVERRIDE := true

# Enable mainline checking
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed

# Overrides
PRODUCT_NAME := lineage_sdk_tv_arm
PRODUCT_MODEL := LineageOS Android TV SDK built for ARM

PRODUCT_SDK_ADDON_NAME := lineage
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := $(LOCAL_PATH)/source.properties
