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

# Makefile for producing cmsdk coverage reports.
# Run "make cmsdk-test-coverage" in the $ANDROID_BUILD_TOP directory.

cts_api_coverage_exe := $(HOST_OUT_EXECUTABLES)/cts-api-coverage
dexdeps_exe := $(HOST_OUT_EXECUTABLES)/dexdeps

coverage_out := $(HOST_OUT)/cmsdk-api-coverage

api_text_description := vendor/cmsdk/api/cm_current.txt
api_xml_description := $(coverage_out)/api.xml
$(api_xml_description) : $(api_text_description) $(APICHECK)
	$(hide) echo "Converting API file to XML: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(APICHECK_COMMAND) -convert2xml $< $@

cmsdk-test-coverage-report := $(coverage_out)/test-coverage.html

cmsdk_tests_apk := $(call intermediates-dir-for,APPS,CMPlatformTests)/package.apk
cmsdk_api_coverage_dependencies := $(cts_api_coverage_exe) $(dexdeps_exe) $(api_xml_description)

$(cmsdk-test-coverage-report): PRIVATE_TEST_CASES := $(cmsdk_tests_apk)
$(cmsdk-test-coverage-report): PRIVATE_CTS_API_COVERAGE_EXE := $(cts_api_coverage_exe)
$(cmsdk-test-coverage-report): PRIVATE_DEXDEPS_EXE := $(dexdeps_exe)
$(cmsdk-test-coverage-report): PRIVATE_API_XML_DESC := $(api_xml_description)
$(cmsdk-test-coverage-report): $(cmsdk_tests_apk) $(cmsdk_api_coverage_dependencies) | $(ACP)
	$(call generate-cm-coverage-report,"CMSDK API Coverage Report",\
			$(PRIVATE_TEST_CASES),html)

.PHONY: cmsdk-test-coverage
cmsdk-test-coverage : $(cmsdk-test-coverage-report)

# Put the test coverage report in the dist dir if "cmsdk" is among the build goals.
ifneq ($(filter cmsdk, $(MAKECMDGOALS)),)
  $(call dist-for-goals, cmsdk, $(cmsdk-test-coverage-report):cmsdk-test-coverage-report.html)
endif

# Arguments;
#  1 - Name of the report printed out on the screen
#  2 - List of apk files that will be scanned to generate the report
#  3 - Format of the report
define generate-cm-coverage-report
	$(hide) mkdir -p $(dir $@)
	$(hide) $(PRIVATE_CTS_API_COVERAGE_EXE) -d $(PRIVATE_DEXDEPS_EXE) -a $(PRIVATE_API_XML_DESC) -f $(3) -o $@ $(2) -cm
	@ echo $(1): file://$(ANDROID_BUILD_TOP)/$@
endef

# Reset temp vars
cmsdk_api_coverage_dependencies :=
cmsdk-combined-coverage-report :=
cmsdk-combined-xml-coverage-report :=
cmsdk-verifier-coverage-report :=
cmsdk-test-coverage-report :=
api_xml_description :=
api_text_description :=
coverage_out :=
dexdeps_exe :=
cmsdk_api_coverage_exe :=
cmsdk_verifier_apk :=
android_cmsdk_zip :=
