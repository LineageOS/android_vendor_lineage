# Copyright (C) 2019-2020 The LineageOS Project
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

$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Allow building otatools
TARGET_FORCE_OTA_PACKAGE := true

# Disable soong defined system image for now
USE_SOONG_DEFINED_SYSTEM_IMAGE := false

PRODUCT_SDK_ADDON_NAME := LineageOS
PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP := vendor/lineage/build/target/product/source.properties

# Copy the manifest and properties files for the SDK add-on.
PRODUCT_SDK_ADDON_COPY_FILES += \
    vendor/lineage/build/target/product/sdk/manifest.ini:manifest.ini \
    vendor/lineage/build/target/product/sdk/package.xml:package.xml \

# Rules for public APIs
PRODUCT_SDK_ADDON_STUB_DEFS += vendor/lineage/build/target/product/sdk_addon_stub_defs.txt

# SDK
PRODUCT_PACKAGES += org.lineageos.platform
PRODUCT_SDK_ADDON_COPY_MODULES += org.lineageos.platform:libs/org.lineageos.platform.jar

ifeq ($(HOST_ARCH),x86_64)
    INTERNAL_SDK_HOST_OS_NAME := linux-x86
else
    INTERNAL_SDK_HOST_OS_NAME := linux-$(REAL_HOST_ARCH)
endif
