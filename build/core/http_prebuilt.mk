# Copyright (C) 2015 The CyanogenMod Project
#           (C) 2017 The LineageOS Project
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

ifeq ($(strip $(LOCAL_HTTP_PATH)),)
  $(error LOCAL_HTTP_PATH not defined.)
endif

ifeq ($(strip $(LOCAL_HTTP_FILENAME)),)
  $(error LOCAL_HTTP_FILENAME not defined.)
endif

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/$(LOCAL_HTTP_FILENAME)

$(LOCAL_PREBUILT_MODULE_FILE): filename := $(LOCAL_HTTP_FILENAME)

$(LOCAL_PREBUILT_MODULE_FILE):
	$(hide) curl -L $(LOCAL_HTTP_PATH) --create-dirs -o $(dir $@)/$(filename) --compressed -H "Accept-Encoding: gzip,deflate,sdch"
	@echo "Download: $@"

include $(BUILD_PREBUILT)
