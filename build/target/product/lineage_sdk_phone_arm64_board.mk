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

# 2.0G + 8M
BOARD_SUPER_PARTITION_SIZE := 2155872256
BOARD_EMULATOR_DYNAMIC_PARTITIONS_SIZE := 2147483648

PRODUCT_SDK_ADDON_COPY_FILES += \
    device/generic/goldfish/data/etc/advancedFeatures.ini.arm:images/arm64-v8a/advancedFeatures.ini \
    device/generic/goldfish/data/etc/encryptionkey.img:images/arm64-v8a/encryptionkey.img \
    $(EMULATOR_KERNEL_FILE):images/arm64-v8a/kernel-ranchu
