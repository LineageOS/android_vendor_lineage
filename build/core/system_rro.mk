# Copyright (C) 2018 The LineageOS Project
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

#############################################################################
## Standard rules for installing runtime resouce overlay APKs.
##
## Set LOCAL_RRO_THEME to the theme name if the package should apply only to
## a particular theme as set by ro.boot.vendor.overlay.theme system property.
##
## If LOCAL_RRO_THEME is not set, the package will apply always, independent
## of themes.
##
#############################################################################

LOCAL_IS_RUNTIME_RESOURCE_OVERLAY := true

ifneq ($(LOCAL_SRC_FILES),)
  $(error runtime resource overlay package should not contain sources)
endif

ifeq ($(LOCAL_RRO_THEME),)
  LOCAL_MODULE_PATH := $(TARGET_OUT)/overlay
else
  LOCAL_MODULE_PATH := $(TARGET_OUT)/overlay/$(LOCAL_RRO_THEME)
endif

include $(BUILD_SYSTEM)/package.mk

