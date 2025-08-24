# Copyright (C) 2023 The LineageOS Project
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

ifdef MANIFEST_EXCLUDES
MANIFEST_EXCLUDES := |$(MANIFEST_EXCLUDES)
endif

include $(CLEAR_VARS)

LOCAL_MODULE         := build-manifest
LOCAL_MODULE_SUFFIX  := .xml
LOCAL_MODULE_CLASS   := ETC
LOCAL_PRODUCT_MODULE := true

_build-manifest_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_build-manifest_xml := $(_build-manifest_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_build-manifest_xml):
	mkdir -p $(dir $@)
	python3 .repo/repo/repo manifest -o - -r | grep -Ev "proprietary_$(MANIFEST_EXCLUDES)" > $@

include $(BUILD_SYSTEM)/base_rules.mk
