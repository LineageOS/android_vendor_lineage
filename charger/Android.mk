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
lineage_charger_density := mdpi
ifneq (,$(TARGET_SCREEN_DENSITY))
lineage_charger_density := $(strip \
  $(or $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 560))),1),xxxhdpi),\
       $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 400))),1),xxhdpi),\
       $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 280))),1),xhdpi),\
       $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 200))),1),hdpi,mdpi)))
else ifneq (,$(filter mdpi hdpi xhdpi xxhdpi xxxhdpi,$(PRODUCT_AAPT_PREF_CONFIG)))
# If PRODUCT_AAPT_PREF_CONFIG includes a dpi bucket, then use that value.
lineage_charger_density := $(PRODUCT_AAPT_PREF_CONFIG)
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
LOCAL_MODULE := lineage_charger_battery_scale_vendor
LOCAL_MODULE_STEM := battery_scale.png
LOCAL_SRC_FILES := $(lineage_charger_density)/battery_scale.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/images/charger
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
LOCAL_MODULE := lineage_charger_battery_fail_vendor
LOCAL_MODULE_STEM := battery_fail.png
LOCAL_SRC_FILES := $(lineage_charger_density)/battery_fail.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_font
LOCAL_MODULE_STEM := percent_font.png
LOCAL_SRC_FILES := $(lineage_charger_density)/percent_font.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_font_vendor
LOCAL_MODULE_STEM := percent_font.png
LOCAL_SRC_FILES := $(lineage_charger_density)/percent_font.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/images/charger
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_animation
LOCAL_MODULE_STEM := animation.txt
LOCAL_SRC_FILES := animation.txt
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT_ETC)/res/values/charger
LOCAL_REQUIRED_MODULES := lineage_charger_battery_scale lineage_charger_battery_fail lineage_charger_font
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := lineage_charger_animation_vendor
LOCAL_MODULE_STEM := animation.txt
LOCAL_SRC_FILES := animation.txt
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)/res/values/charger
LOCAL_REQUIRED_MODULES := lineage_charger_battery_scale_vendor lineage_charger_battery_fail_vendor lineage_charger_font_vendor
include $(BUILD_PREBUILT)
