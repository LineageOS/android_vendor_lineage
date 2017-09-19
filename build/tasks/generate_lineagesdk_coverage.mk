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

# Makefile for producing lineagesdk coverage reports.
# Run "make lineagesdk-test-coverage" in the $ANDROID_BUILD_TOP directory.

lineagesdk_api_coverage_exe := $(HOST_OUT_EXECUTABLES)/lineagesdk-api-coverage
dexdeps_exe := $(HOST_OUT_EXECUTABLES)/dexdeps

coverage_out := $(HOST_OUT)/lineagesdk-api-coverage

api_text_description := lineage-sdk/api/lineage_current.txt
api_xml_description := $(coverage_out)/api.xml
$(api_xml_description) : $(api_text_description) $(APICHECK)
	$(hide) echo "Converting API file to XML: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(APICHECK_COMMAND) -convert2xml $< $@

lineagesdk-test-coverage-report := $(coverage_out)/lineagesdk-test-coverage.html

lineagesdk_tests_apk := $(call intermediates-dir-for,APPS,CMPlatformTests)/package.apk
lineagesettingsprovider_tests_apk := $(call intermediates-dir-for,APPS,LineageSettingsProviderTests)/package.apk
lineagesdk_api_coverage_dependencies := $(lineagesdk_api_coverage_exe) $(dexdeps_exe) $(api_xml_description)

$(lineagesdk-test-coverage-report): PRIVATE_TEST_CASES := $(lineagesdk_tests_apk) $(lineagesettingsprovider_tests_apk)
$(lineagesdk-test-coverage-report): PRIVATE_LINEAGESDK_API_COVERAGE_EXE := $(lineagesdk_api_coverage_exe)
$(lineagesdk-test-coverage-report): PRIVATE_DEXDEPS_EXE := $(dexdeps_exe)
$(lineagesdk-test-coverage-report): PRIVATE_API_XML_DESC := $(api_xml_description)
$(lineagesdk-test-coverage-report): $(lineagesdk_tests_apk) $(lineagesettingsprovider_tests_apk) $(lineagesdk_api_coverage_dependencies) | $(ACP)
	$(call generate-lineage-coverage-report,"LINEAGESDK API Coverage Report",\
			$(PRIVATE_TEST_CASES),html)

.PHONY: lineagesdk-test-coverage
lineagesdk-test-coverage : $(lineagesdk-test-coverage-report)

# Put the test coverage report in the dist dir if "lineagesdk" is among the build goals.
ifneq ($(filter lineagesdk, $(MAKECMDGOALS)),)
  $(call dist-for-goals, lineagesdk, $(lineagesdk-test-coverage-report):lineagesdk-test-coverage-report.html)
endif

# Arguments;
#  1 - Name of the report printed out on the screen
#  2 - List of apk files that will be scanned to generate the report
#  3 - Format of the report
define generate-lineage-coverage-report
	$(hide) mkdir -p $(dir $@)
	$(hide) $(PRIVATE_LINEAGESDK_API_COVERAGE_EXE) -d $(PRIVATE_DEXDEPS_EXE) -a $(PRIVATE_API_XML_DESC) -f $(3) -o $@ $(2) -cm
	@ echo $(1): file://$@
endef

# Reset temp vars
lineagesdk_api_coverage_dependencies :=
lineagesdk-combined-coverage-report :=
lineagesdk-combined-xml-coverage-report :=
lineagesdk-verifier-coverage-report :=
lineagesdk-test-coverage-report :=
api_xml_description :=
api_text_description :=
coverage_out :=
dexdeps_exe :=
lineagesdk_api_coverage_exe :=
lineagesdk_verifier_apk :=
android_lineagesdk_zip :=
