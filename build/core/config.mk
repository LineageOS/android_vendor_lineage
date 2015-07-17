# Copyright (C) 2015 The CyanogenMod Project
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

CM_SRC_API_DIR := $(TOPDIR)prebuilts/cmsdk/api
CM_SRC_SYSTEM_API_DIR := $(TOPDIR)prebuilts/cmsdk/system-api
INTERNAL_CM_PLATFORM_API_FILE := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/cm_public_api.txt
INTERNAL_CM_PLATFORM_REMOVED_API_FILE := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/cm_removed.txt
INTERNAL_CM_PLATFORM_SYSTEM_API_FILE := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/cm_system-api.txt
INTERNAL_CM_PLATFORM_SYSTEM_REMOVED_API_FILE := $(TARGET_OUT_COMMON_INTERMEDIATES)/PACKAGING/cm_system-removed.txt
FRAMEWORK_CM_PLATFORM_API_FILE := $(TOPDIR)vendor/cmsdk/api/cm_current.txt
FRAMEWORK_CM_PLATFORM_REMOVED_API_FILE := $(TOPDIR)vendor/cmsdk/api/cm_removed.txt
FRAMEWORK_CM_PLATFORM_SYSTEM_API_FILE := $(TOPDIR)vendor/cmsdk/system-api/cm_system-current.txt
FRAMEWORK_CM_PLATFORM_SYSTEM_REMOVED_API_FILE := $(TOPDIR)vendor/cmsdk/system-api/cm_system-removed.txt

BUILD_MAVEN_PREBUILT := $(TOP)/vendor/cm/build/core/maven_artifact.mk
