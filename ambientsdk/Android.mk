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

include $(CLEAR_VARS)

LOCAL_MODULE := ambientsdk
LOCAL_MODULE_CLASS := JAVA_LIBRARIES
LOCAL_UNINSTALLABLE_MODULE := true

LOCAL_MAVEN_REPO := https://repo1.maven.org/maven2
LOCAL_MAVEN_GROUP := com.cyngn.ambient
LOCAL_MAVEN_ARTIFACT := ambientsdk
LOCAL_MAVEN_VERSION := 1.4.0
LOCAL_MAVEN_PACKAGING := aar

include $(BUILD_MAVEN_PREBUILT)
