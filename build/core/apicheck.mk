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
ifeq (,$(filter true, $(WITHOUT_CHECK_API) $(TARGET_BUILD_PDK)))

.PHONY: checkapi-cm

# Run the checkapi rules by default.
droidcore: checkapi-cm

cm_last_released_sdk_version := $(lastword $(call numerically_sort, \
            $(filter-out current, \
                $(patsubst $(CM_SRC_API_DIR)/%.txt,%, $(wildcard $(CM_SRC_API_DIR)/*.txt)) \
             )\
        ))

.PHONY: check-cm-public-api
checkapi-cm : check-cm-public-api

.PHONY: update-cm-api

# INTERNAL_CM_PLATFORM_API_FILE is the one build by droiddoc.
# Note that since INTERNAL_CM_PLATFORM_API_FILE  is the byproduct of api-stubs module,
# (See vendor/cmsdk/Android.mk)
# we need to add api-stubs as additional dependency of the api check.

# Check that the API we're building hasn't broken the last-released
# SDK version.
$(eval $(call check-api, \
    checkpublicapi-cm-last, \
    $(CM_SRC_API_DIR)/$(cm_last_released_sdk_version).txt, \
    $(INTERNAL_CM_PLATFORM_API_FILE), \
    $(FRAMEWORK_CM_PLATFORM_REMOVED_API_FILE), \
    $(INTERNAL_CM_PLATFORM_REMOVED_API_FILE), \
    cat $(BUILD_SYSTEM)/apicheck_msg_last.txt, \
    check-cm-public-api, \
    $(call doc-timestamp-for, cm-api-stubs) \
    ))


# Check that the API we're building hasn't changed from the not-yet-released
# SDK version.
$(eval $(call check-api, \
    checkpublicapi-cm-current, \
    $(FRAMEWORK_CM_PLATFORM_API_FILE), \
    $(INTERNAL_CM_PLATFORM_API_FILE), \
    $(FRAMEWORK_CM_PLATFORM_REMOVED_API_FILE), \
    $(INTERNAL_CM_PLATFORM_REMOVED_API_FILE), \
    cat $(BUILD_SYSTEM)/apicheck_msg_current.txt, \
    check-cm-public-api, \
    $(call doc-timestamp-for, cm-api-stubs) \
    ))

.PHONY: update-cm-public-api
update-cm-public-api: $(INTERNAL_CM_PLATFORM_API_FILE) | $(ACP)
	@echo -e ${CL_GRN}"Copying cm_current.txt"${CL_RST}
	$(hide) $(ACP) $(INTERNAL_CM_PLATFORM_API_FILE) $(FRAMEWORK_CM_PLATFORM_API_FILE)
	@echo -e ${CL_GRN}"Copying cm_removed.txt"${CL_RST}
	$(hide) $(ACP) $(INTERNAL_CM_PLATFORM_REMOVED_API_FILE) $(FRAMEWORK_CM_PLATFORM_REMOVED_API_FILE)

update-cm-api : update-cm-public-api

#####################Check System API#####################
.PHONY: check-cm-system-api
checkapi-cm : check-cm-system-api

# Check that the Cyanogen System API we're building hasn't broken the last-released
# SDK version.
$(eval $(call check-api, \
    checksystemapi-cm-last, \
    $(CM_SRC_SYSTEM_API_DIR)/$(cm_last_released_sdk_version).txt, \
    $(INTERNAL_CM_PLATFORM_SYSTEM_API_FILE), \
    $(FRAMEWORK_CM_PLATFORM_SYSTEM_REMOVED_API_FILE), \
    $(INTERNAL_CM_PLATFORM_SYSTEM_REMOVED_API_FILE), \
    cat $(BUILD_SYSTEM)/apicheck_msg_last.txt, \
    check-cm-system-api, \
    $(call doc-timestamp-for, cm-system-api-stubs) \
    ))

# Check that the System API we're building hasn't changed from the not-yet-released
# SDK version.
$(eval $(call check-api, \
    checksystemapi-cm-current, \
    $(FRAMEWORK_CM_PLATFORM_SYSTEM_API_FILE), \
    $(INTERNAL_CM_PLATFORM_SYSTEM_API_FILE), \
    $(FRAMEWORK_CM_PLATFORM_SYSTEM_REMOVED_API_FILE), \
    $(INTERNAL_CM_PLATFORM_SYSTEM_REMOVED_API_FILE), \
    cat $(BUILD_SYSTEM)/apicheck_msg_current.txt, \
    check-cm-system-api, \
    $(call doc-timestamp-for, cm-system-api-stubs) \
    ))

.PHONY: update-cm-system-api
update-cm-api : update-cm-system-api

update-cm-system-api: $(INTERNAL_PLATFORM_CM_SYSTEM_API_FILE) | $(ACP)
	@echo Copying cm_system-current.txt
	$(hide) $(ACP) $(INTERNAL_CM_PLATFORM_SYSTEM_API_FILE) $(FRAMEWORK_CM_PLATFORM_SYSTEM_API_FILE)
	@echo Copying cm_system-removed.txt
	$(hide) $(ACP) $(INTERNAL_CM_PLATFORM_SYSTEM_REMOVED_API_FILE) $(FRAMEWORK_CM_PLATFORM_SYSTEM_REMOVED_API_FILE)

.PHONY: update-cm-prebuilts-latest-public-api
current_sdk_release_text_file := $(CM_SRC_API_DIR)/$(cm_last_released_sdk_version).txt
current_system_api_release_text_file := $(CM_SRC_SYSTEM_API_DIR)/$(cm_last_released_sdk_version).txt

update-cm-prebuilts-latest-public-api: $(FRAMEWORK_CM_PLATFORM_API_FILE) | $(ACP)
	@echo -e ${CL_GRN}"Publishing cm_current.txt as latest API release"${CL_RST}
	$(hide) $(ACP) $(FRAMEWORK_CM_PLATFORM_API_FILE) $(current_sdk_release_text_file)
	@echo -e ${CL_GRN}"Publishing cm_current.txt as latest system API release"${CL_RST}
	$(hide) $(ACP) $(FRAMEWORK_CM_PLATFORM_SYSTEM_API_FILE) $(current_system_api_release_text_file)

endif
