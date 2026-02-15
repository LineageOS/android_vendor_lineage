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

$(call inherit-product, device/generic/car/gsi_car_arm64.mk)

include vendor/lineage/build/target/product/lineage_generic_car_target.mk

PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

TARGET_NO_KERNEL_OVERRIDE := true

# Disable EPPE to suppress the following failures :
#   -> DDPanelRRO : packages/apps/Car/References/scalable-ui/dewd_reference.mk
# These are pulled in by mk files that enable Scalable-UI,
# Refer car_dewd_common.mk and gsi_car_base.mk for scalable-ui config.
TARGET_DISABLE_EPPE := true

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := strict

PRODUCT_NAME := lineage_gsi_car_arm64
