#
# Copyright (C) 2016 The CyanogenMod Project
#               2017 The LineageOS Project
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

ifeq ($(TARGET_SCREEN_WIDTH),)
    $(warning TARGET_SCREEN_WIDTH is not set, using default value: 1080)
    TARGET_SCREEN_WIDTH := 1080
endif
ifeq ($(TARGET_SCREEN_HEIGHT),)
    $(warning TARGET_SCREEN_HEIGHT is not set, using default value: 1920)
    TARGET_SCREEN_HEIGHT := 1920
endif

define build-bootanimation
    sh vendor/lineage/bootanimation/generate-bootanimation.sh \
    $(TARGET_SCREEN_WIDTH) \
    $(TARGET_SCREEN_HEIGHT) \
    $(TARGET_BOOTANIMATION_HALF_RES)
endef

TARGET_GENERATED_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_GENERATED_BOOTANIMATION):
	@echo "Building bootanimation"
	$(build-bootanimation)

ifeq ($(TARGET_BOOTANIMATION),)
    TARGET_BOOTANIMATION := $(TARGET_GENERATED_BOOTANIMATION)
    ifeq ($(shell command -v mogrify),)
        $(info **********************************************)
        $(info The boot animation could not be generated as)
        $(info ImageMagick is not installed in your system.)
        $(info $(space))
        $(info Please install ImageMagick from this website:)
        $(info https://imagemagick.org/script/binary-releases.php)
        $(info **********************************************)
        $(error stop)
    endif
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bootanimation.zip
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT)/media

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(TARGET_BOOTANIMATION)
	@mkdir -p $(dir $@)
	@cp $(TARGET_BOOTANIMATION) $@
