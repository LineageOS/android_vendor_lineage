# Copyright (C) 2020 The Proton AOSP Project
# Copyright (C) 2025 The LineageOS Project
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

# Plasma Mobile sounds (mixed CC0 / CC BY 4.0 / CC BY-SA 4.0)
# Source: https://invent.kde.org/plasma-mobile/plasma-mobile-sounds
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/notifications/,$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/alarms/,$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/ringtones/,$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones)
