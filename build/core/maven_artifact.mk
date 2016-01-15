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

ifeq ($(strip $(LOCAL_MAVEN_GROUP)),)
  $(error LOCAL_MAVEN_GROUP not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_ARTIFACT)),)
  $(error LOCAL_MAVEN_ARTIFACT not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_VERSION)),)
  $(error LOCAL_MAVEN_VERSION not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_REPO)),)
  $(error LOCAL_MAVEN_REPO not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_PACKAGING)),)
  LOCAL_MAVEN_PACKAGING := jar
endif

artifact_filename := $(LOCAL_MAVEN_GROUP).$(LOCAL_MAVEN_ARTIFACT)-$(LOCAL_MAVEN_VERSION)$(if $(LOCAL_MAVEN_CLASSIFIER),-$(LOCAL_MAVEN_CLASSIFIER)).$(LOCAL_MAVEN_PACKAGING)

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/$(artifact_filename)

$(LOCAL_PREBUILT_MODULE_FILE): repo := $(LOCAL_MAVEN_REPO)
$(LOCAL_PREBUILT_MODULE_FILE): group := $(LOCAL_MAVEN_GROUP)
$(LOCAL_PREBUILT_MODULE_FILE): artifact := $(LOCAL_MAVEN_ARTIFACT)
$(LOCAL_PREBUILT_MODULE_FILE): version := $(LOCAL_MAVEN_VERSION)
$(LOCAL_PREBUILT_MODULE_FILE): packaging := $(LOCAL_MAVEN_PACKAGING)
$(LOCAL_PREBUILT_MODULE_FILE): classifier := $(LOCAL_MAVEN_CLASSIFIER)
$(LOCAL_PREBUILT_MODULE_FILE):
	$(hide) mvn -q org.apache.maven.plugins:maven-dependency-plugin:2.10:get \
				   org.apache.maven.plugins:maven-dependency-plugin:2.10:copy \
		-DremoteRepositories=central::::$(repo) \
		-Dartifact=$(group):$(artifact):$(version):$(packaging)$(if $(classifier),:$(classifier)) \
		-Dmdep.prependGroupId=true \
		-Dmdep.overWriteSnapshots=true \
		-Dmdep.overWriteReleases=true \
		-Dtransitive=false \
		-DoutputDirectory=$(dir $@)
	@echo -e ${CL_GRN}"Download:"${CL_RST}" $@"

ifneq ($(filter-out disabled, $(LOCAL_JACK_ENABLED)),)
# This is required to be defined before the LOCAL_MODULES target below gets defined, it's a NOOP registered again in
# BUILD_PREBUILT.  This is done because BUILD_PREBUILT doesn't actually handle generating the .jack files properly and
# only generates a target but doesn't set the LOCAL_MODULE dependent on it.
$(call intermediates-dir-for,JAVA_LIBRARIES,$(LOCAL_MODULE),,COMMON):

# This adds another step required for LOCAL_MODULE to be completed -- generating the jack file, it just so happens
# to be built when doing a brunch, but not when doing an mmm, so this makes it work with both
$(LOCAL_MODULE): $(call intermediates-dir-for,JAVA_LIBRARIES,$(LOCAL_MODULE),,COMMON)/classes.jack
endif # LOCAL_JACK_ENABLED is full or partial

include $(BUILD_PREBUILT)

# the "fetchprebuilts" target will go through and pre-download all of the maven dependencies in the tree
fetchprebuilts: $(LOCAL_PREBUILT_MODULE_FILE)