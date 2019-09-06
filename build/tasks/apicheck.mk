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

#
# Rules for running apicheck to confirm that you haven't broken
# api compatibility or added apis illegally.
#

# skip api check for PDK buid
ifeq (,$(filter true, $(WITHOUT_CHECK_API) $(TARGET_BUILD_PDK) $(TARGET_DISABLE_LINEAGE_SDK)))

.PHONY: checkapi-lineage

# Run the checkapi rules by default.
droidcore: checkapi-lineage

# Validate against previous release platform sdk version api text within prebuilts
lineage_last_released_sdk_version := $(LINEAGE_PLATFORM_SDK_VERSION)

.PHONY: check-lineage-public-api
checkapi-lineage : check-lineage-public-api

.PHONY: update-lineage-api

# INTERNAL_LINEAGE_PLATFORM_API_FILE is the one build by droiddoc.
# Note that since INTERNAL_LINEAGE_PLATFORM_API_FILE  is the byproduct of api-stubs module,
# (See lineage-sdk/Android.mk)
# we need to add api-stubs as additional dependency of the api check.

$(INTERNAL_LINEAGE_PLATFORM_API_FILE):

# Check that the API we're building hasn't broken the last-released
# SDK version.
$(eval $(call check-api, \
    checkpublicapi-lineage-last, \
    $(LINEAGE_SRC_API_DIR)/$(lineage_last_released_sdk_version).txt, \
    $(INTERNAL_LINEAGE_PLATFORM_API_FILE), \
    $(FRAMEWORK_LINEAGE_PLATFORM_REMOVED_API_FILE), \
    $(INTERNAL_LINEAGE_PLATFORM_REMOVED_API_FILE), \
    -hide 2 -hide 3 -hide 4 -hide 5 -hide 6 -hide 24 -hide 25 -hide 26 -hide 27 \
    -error 7 -error 8 -error 9 -error 10 -error 11 -error 12 -error 13 -error 14 -error 15 \
    -error 16 -error 17 -error 18 , \
    cat $(FRAMEWORK_LINEAGE_API_NEEDS_UPDATE_TEXT), \
    check-lineage-public-api, \
    $(call doc-timestamp-for,lineage-api-stubs) \
    ))

# Check that the API we're building hasn't changed from the not-yet-released
# SDK version.
$(eval $(call check-api, \
    checkpublicapi-lineage-current, \
    $(FRAMEWORK_LINEAGE_PLATFORM_API_FILE), \
    $(INTERNAL_LINEAGE_PLATFORM_API_FILE), \
    $(FRAMEWORK_LINEAGE_PLATFORM_REMOVED_API_FILE), \
    $(INTERNAL_LINEAGE_PLATFORM_REMOVED_API_FILE), \
    -error 2 -error 3 -error 4 -error 5 -error 6 \
    -error 7 -error 8 -error 9 -error 10 -error 11 -error 12 -error 13 -error 14 -error 15 \
    -error 16 -error 17 -error 18 -error 19 -error 20 -error 21 -error 23 -error 24 \
    -error 25 -error 26 -error 27, \
    cat $(FRAMEWORK_LINEAGE_API_NEEDS_UPDATE_TEXT), \
    check-lineage-public-api, \
    $(call doc-timestamp-for,lineage-api-stubs) \
    ))

.PHONY: update-lineage-public-api
update-lineage-public-api: $(INTERNAL_LINEAGE_PLATFORM_API_FILE) | $(ACP)
	@echo "Copying lineage_current.txt"
	$(hide) $(ACP) $(INTERNAL_LINEAGE_PLATFORM_API_FILE) $(FRAMEWORK_LINEAGE_PLATFORM_API_FILE)
	@echo "Copying lineage_removed.txt"
	$(hide) $(ACP) $(INTERNAL_LINEAGE_PLATFORM_REMOVED_API_FILE) $(FRAMEWORK_LINEAGE_PLATFORM_REMOVED_API_FILE)

update-lineage-api : update-lineage-public-api

.PHONY: update-lineage-prebuilts-latest-public-api
current_sdk_release_text_file := $(LINEAGE_SRC_API_DIR)/$(lineage_last_released_sdk_version).txt

update-lineage-prebuilts-latest-public-api: $(FRAMEWORK_LINEAGE_PLATFORM_API_FILE) | $(ACP)
	@echo "Publishing lineage_current.txt as latest API release"
	$(hide) $(ACP) $(FRAMEWORK_LINEAGE_PLATFORM_API_FILE) $(current_sdk_release_text_file)

endif
