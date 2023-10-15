# Copyright (C) 2017 Unlegacy-Android
# Copyright (C) 2017,2020 The LineageOS Project
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

# -----------------------------------------------------------------
# Lineage OTA update package

LINEAGE_TARGET_PACKAGE := $(PRODUCT_OUT)/lineage-$(LINEAGE_VERSION).zip

SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

ifeq ($(BOARD_BUILD_RETROFIT_DYNAMIC_PARTITIONS_OTA_PACKAGE),true)
LINEAGE_OTA_PACKAGE_TARGET := $(INTERNAL_OTA_RETROFIT_DYNAMIC_PARTITIONS_PACKAGE_TARGET)
else
LINEAGE_OTA_PACKAGE_TARGET := $(INTERNAL_OTA_PACKAGE_TARGET)
endif

$(LINEAGE_TARGET_PACKAGE): $(LINEAGE_OTA_PACKAGE_TARGET)
	$(hide) ln -f $(LINEAGE_OTA_PACKAGE_TARGET) $(LINEAGE_TARGET_PACKAGE)
	$(hide) $(SHA256) $(LINEAGE_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(LINEAGE_TARGET_PACKAGE).sha256sum
	@echo "Package Complete: $(LINEAGE_TARGET_PACKAGE)" >&2

.PHONY: bacon
bacon: $(LINEAGE_TARGET_PACKAGE) $(DEFAULT_GOAL)
