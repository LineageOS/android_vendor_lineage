#
# Copyright (C) 2010 The Android Open Source Project
# Copyright (C) 2016 The CyanogenMod Project
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

# Makefile for producing lineage sdk coverage reports.
# Run "make lineage-sdk-test-coverage" in the $ANDROID_BUILD_TOP directory.

lineage_sdk_api_coverage_exe := $(HOST_OUT_EXECUTABLES)/lineage-sdk-api-coverage
dexdeps_exe := $(HOST_OUT_EXECUTABLES)/dexdeps

coverage_out := $(HOST_OUT)/lineage-sdk-api-coverage

api_text_description := lineage-sdk/api/lineage_current.txt
api_xml_description := $(coverage_out)/api.xml
$(api_xml_description) : $(api_text_description) $(APICHECK)
	$(hide) echo "Converting API file to XML: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(APICHECK_COMMAND) -convert2xml $< $@

lineage-sdk-test-coverage-report := $(coverage_out)/lineage-sdk-test-coverage.html

lineage_sdk_tests_apk := $(call intermediates-dir-for,APPS,CMPlatformTests)/package.apk
lineagesettingsprovider_tests_apk := $(call intermediates-dir-for,APPS,LineageSettingsProviderTests)/package.apk
lineage_sdk_api_coverage_dependencies := $(lineage_sdk_api_coverage_exe) $(dexdeps_exe) $(api_xml_description)

$(lineage-sdk-test-coverage-report): PRIVATE_TEST_CASES := $(lineage_sdk_tests_apk) $(lineagesettingsprovider_tests_apk)
$(lineage-sdk-test-coverage-report): PRIVATE_LINEAGE_SDK_API_COVERAGE_EXE := $(lineage_sdk_api_coverage_exe)
$(lineage-sdk-test-coverage-report): PRIVATE_DEXDEPS_EXE := $(dexdeps_exe)
$(lineage-sdk-test-coverage-report): PRIVATE_API_XML_DESC := $(api_xml_description)
$(lineage-sdk-test-coverage-report): $(lineage_sdk_tests_apk) $(lineagesettingsprovider_tests_apk) $(lineage_sdk_api_coverage_dependencies) | $(ACP)
	$(call generate-lineage-coverage-report,"LINEAGE-SDK API Coverage Report",\
			$(PRIVATE_TEST_CASES),html)

.PHONY: lineage-sdk-test-coverage
lineage-sdk-test-coverage : $(lineage-sdk-test-coverage-report)

# Put the test coverage report in the dist dir if "lineage-sdk" is among the build goals.
ifneq ($(filter lineage-sdk, $(MAKECMDGOALS)),)
  $(call dist-for-goals, lineage-sdk, $(lineage-sdk-test-coverage-report):lineage-sdk-test-coverage-report.html)
endif

# Arguments;
#  1 - Name of the report printed out on the screen
#  2 - List of apk files that will be scanned to generate the report
#  3 - Format of the report
define generate-lineage-coverage-report
	$(hide) mkdir -p $(dir $@)
	$(hide) $(PRIVATE_LINEAGE_SDK_API_COVERAGE_EXE) -d $(PRIVATE_DEXDEPS_EXE) -a $(PRIVATE_API_XML_DESC) -f $(3) -o $@ $(2) -cm
	@ echo $(1): file://$@
endef

# Reset temp vars
lineage_sdk_api_coverage_dependencies :=
lineage-sdk-combined-coverage-report :=
lineage-sdk-combined-xml-coverage-report :=
lineage-sdk-verifier-coverage-report :=
lineage-sdk-test-coverage-report :=
api_xml_description :=
api_text_description :=
coverage_out :=
dexdeps_exe :=
lineage_sdk_api_coverage_exe :=
lineage_sdk_verifier_apk :=
android_lineage_sdk_zip :=
