# Copyright (C) 2018-2022 The LineageOS Project
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

$(call inherit-product, device/generic/car/sdk_car_arm64.mk)

include device/generic/goldfish/board/kernel/arm64.mk

include vendor/lineage/build/target/product/lineage_generic_car_target.mk

# Disable EPPE to suppress the following failures :
#   -> android.hardware.bluetooth.audio@2.2-impl : device/generic/car/emulator/usbpt/bluetooth/bluetooth.mk
#   -> vndk-sp : device/generic/car/emulator/car_emulator_vendor.mk
#   -> RotaryIME and RotaryPlayground : device/generic/car/emulator/rotary/car_rotary.mk
# The rotary modules are present (unbundled) in https://android.googlesource.com/platform/packages/apps/Car/tests but seem to be outdated.
TARGET_DISABLE_EPPE := true

# Disabled till device/generic/car/emulator/car_emulator_vendor.mk stops using PRODUCT_SYSTEM_PROPERTIES.
# Android 16 QPR2 introduced stricter checks in build/soong/fsgen/artifact_path_requirements.go,
# which disallows setting PRODUCT_SYSTEM_PROPERTIES when artifact requirements for the path are enforced by a different mk file.
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := false

PRODUCT_NAME := lineage_sdk_car_arm64

PRODUCT_SDK_ADDON_NAME := lineage
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := $(LOCAL_PATH)/source.properties
