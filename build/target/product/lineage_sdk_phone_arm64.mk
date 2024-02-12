# Copyright (C) 2021-2024 The LineageOS Project
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

$(call inherit-product, device/generic/goldfish/64bitonly/product/sdk_phone64_arm64.mk)
$(call inherit-product, vendor/lineage/build/target/product/lineage_sdk_phone_arm64_board.mk)

include vendor/lineage/build/target/product/lineage_generic_target.mk

# Always build modules from source
PRODUCT_MODULE_BUILD_FROM_SOURCE := true

# Enable mainline checking
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed

# Overrides
PRODUCT_NAME := lineage_sdk_phone_arm64
PRODUCT_MODEL := LineageOS Android SDK built for arm64

PRODUCT_SDK_ADDON_NAME := lineage
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := vendor/lineage/build/target/product/source.properties
