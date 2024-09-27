# Copyright (C) 2018-2020 The LineageOS Project
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

$(call inherit-product, device/generic/common/gsi_arm.mk)

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

include vendor/lineage/build/target/product/lineage_generic_target.mk

PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

TARGET_NO_KERNEL_OVERRIDE := true

PRODUCT_NAME := lineage_gsi_arm

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS :=
