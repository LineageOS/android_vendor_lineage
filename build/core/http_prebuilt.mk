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

ifeq ($(strip $(LOCAL_HTTP_MD5SUM)),)
  $(error LOCAL_HTTP_MD5SUM not defined.)
endif

PREBUILT_MODULE_ARCHIVE := vendor/cm/prebuilt/archive/$(LOCAL_MODULE)

PREBUILT_MODULE_FILE := $(PREBUILT_MODULE_ARCHIVE)/$(LOCAL_HTTP_FILENAME)

PREBUILT_MODULE_MD5SUM := $(PREBUILT_MODULE_ARCHIVE)/md5sum

HTTP_FILE_URL := $(LOCAL_HTTP_PATH)/$(LOCAL_HTTP_FILENAME)
HTTP_FILE_MD5_URL := $(LOCAL_HTTP_PATH)/$(LOCAL_HTTP_MD5SUM)

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/$(LOCAL_HTTP_FILENAME)

$(LOCAL_PREBUILT_MODULE_FILE): filename := $(LOCAL_HTTP_FILENAME)
$(LOCAL_PREBUILT_MODULE_FILE): checksum := $(PREBUILT_MODULE_MD5SUM)
$(LOCAL_PREBUILT_MODULE_FILE): filepath := $(PREBUILT_MODULE_FILE)
$(LOCAL_PREBUILT_MODULE_FILE): version  := $(LOCAL_HTTP_FILE_VERSION)

define curl-checksum
  @echo "Pulling comparison md5sum for $(filename)"
  $(call download-prebuilt-module, $(HTTP_FILE_MD5_URL),$(checksum))
endef

define audit-checksum
  @echo "Downloading: $(filename) (version $(version))" -> $(filepath);
  $(hide) if [ ! -f $(filepath) ]; then \
            $(call download-prebuilt-module, $(HTTP_FILE_URL),$(filepath)) \
          else \
            if [ "$(shell echo $(md5sum $(filepath)))" != "$(shell cat $(checksum) | cut -d ' ' -f1)" ]; then \
              rm -rf $(filepath); \
              $(call download-prebuilt-module, $(HTTP_FILE_URL),$(filepath)) \
            fi; \
          fi; \
          rm -f $(checksum);
endef

# $(1) url
# $(2) file output
define download-prebuilt-module
  ./vendor/cm/build/tasks/http_curl_prebuilt.sh $(1) $(2);
endef

define cleanup
  @echo "Copying: $(filename) -> $(dir $@)"
  $(hide) mkdir -p $(dir $@)
  $(hide) cp $(filepath) $(dir $@)/$(filename)
endef

$(LOCAL_PREBUILT_MODULE_FILE):
	$(call curl-checksum)
	$(call audit-checksum)
	$(call cleanup)

include $(BUILD_PREBUILT)

# the "fetchprebuilts" target will go through and pre-download all of the maven dependencies in the tree
fetchprebuilts: $(LOCAL_PREBUILT_MODULE_FILE)

# the "nukeprebuilts" target will evict all archived artifacts
nukeprebuilts:
	  @echo "Removing artifact for $(LOCAL_HTTP_FILENAME)"
	  $(hide) rm -rf $(PREBUILT_MODULE_ARCHIVE)
