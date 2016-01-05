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

full_target := $(call doc-timestamp-for,$(LOCAL_MODULE))

ifeq ($(strip $(LOCAL_MAVEN_POM)),)
  $(error LOCAL_MAVEN_POM not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_REPO)),)
  $(error LOCAL_MAVEN_REPO not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_TARGET_MODULE)),)
  $(error LOCAL_MAVEN_TARGET_MODULE not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_REPO_ID)),)
  $(error LOCAL_MAVEN_REPO_ID not defined.)
endif

$(full_target): pomfile := $(LOCAL_MAVEN_POM)
$(full_target): repo := $(LOCAL_MAVEN_REPO)
$(full_target): path_to_file := $(call intermediates-dir-for,JAVA_LIBRARIES,$(LOCAL_MAVEN_TARGET_MODULE),,COMMON)/javalib.jar
$(full_target): repoId := $(LOCAL_MAVEN_REPO_ID)
$(full_target): classifier := $(LOCAL_MAVEN_CLASSIFIER)
$(full_target): sources := $(LOCAL_MAVEN_SOURCES)
$(full_target): javadoc := $(LOCAL_MAVEN_JAVADOC)
$(full_target): artifact_path := $(LOCAL_MAVEN_ARTIFACT_PATH)
$(full_target): artifact_path ?= $(basename $(path_to_file))

$(full_target): $(LOCAL_MAVEN_TARGET_MODULE) $(path_to_file) $(artifact_path) $(ACP)
	@echo -e ${CL_GRN}"Renaming generated sdk javalib jar"${CL_RST}
	$(hide) $(ACP) $(path_to_file) $(artifact_path)
	@echo -e ${CL_GRN}"Publishing to Maven"${CL_RST}
	$(hide) mvn -e -X gpg:sign-and-deploy-file \
		    -DpomFile=$(pomfile) \
			-Durl=$(repo) \
			-Dfile=$(artifact_path) \
			-DrepositoryId=$(repoId) \
			-Dclassifier=$(classifier) \
			-Dsources=$(sources) \
			-Djavadoc=$(javadoc)
	@echo -e ${CL_GRN}"Publishing:"${CL_RST}" $@"
$(LOCAL_MODULE): $(full_target)