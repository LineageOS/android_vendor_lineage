#
# Copyright (C) 2021 The LineageOS Project
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
#

LOCAL_PATH := $(call my-dir)

# Set lineage_charger_density to the density bucket of the device.
lineage_charger_density := unknown
ifneq (,$(TARGET_RECOVERY_DENSITY))
healthd_density := $(filter %dpi,$(TARGET_RECOVERY_DENSITY))
else
ifneq (,$(PRODUCT_AAPT_PREF_CONFIG))
# If PRODUCT_AAPT_PREF_CONFIG includes a dpi bucket, then use that value.
lineage_charger_density := $(filter %dpi,$(PRODUCT_AAPT_PREF_CONFIG))
else
# Otherwise, use the default medium density.
lineage_charger_density := mdpi
endif
endif

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_battery_scale
LOCAL_MODULE_STEM := battery_scale.png
LOCAL_SRC_FILES := $(lineage_charger_density)/battery_scale.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_battery_fail
LOCAL_MODULE_STEM := battery_fail.png
LOCAL_SRC_FILES := $(lineage_charger_density)/battery_fail.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_animation
LOCAL_MODULE_STEM := animation.txt
LOCAL_SRC_FILES := animation.txt
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/values/charger
LOCAL_REQUIRED_MODULES := lineage_charger_battery_scale lineage_charger_battery_fail
include $(BUILD_PREBUILT)
