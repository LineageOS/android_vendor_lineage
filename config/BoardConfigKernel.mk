# Copyright (C) 2018 The LineageOS Project
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
#
# Kernel build configuration variables
# ====================================
#
# These config vars are usually set in BoardConfig.mk:
#
#   TARGET_KERNEL_SOURCE               = Kernel source dir, optional, defaults
#                                          to kernel/$(TARGET_DEVICE_DIR)
#   TARGET_KERNEL_ADDITIONAL_FLAGS     = Additional make flags, optional
#   TARGET_KERNEL_ARCH                 = Kernel Arch
#   TARGET_KERNEL_CROSS_COMPILE_PREFIX = Compiler prefix (e.g. arm-eabi-)
#                                          defaults to arm-linux-androidkernel- for arm
#                                                      aarch64-linux-androidkernel- for arm64
#                                                      x86_64-linux-androidkernel- for x86
#
#   TARGET_KERNEL_CLANG_COMPILE        = Compile kernel with clang, defaults to false
#
#   KERNEL_TOOLCHAIN_PREFIX            = Overrides TARGET_KERNEL_CROSS_COMPILE_PREFIX,
#                                          Set this var in shell to override
#                                          toolchain specified in BoardConfig.mk
#   KERNEL_TOOLCHAIN                   = Path to toolchain, if unset, assumes
#                                          TARGET_KERNEL_CROSS_COMPILE_PREFIX
#                                          is in PATH
#   USE_CCACHE                         = Enable ccache (global Android flag)

BUILD_TOP := $(shell pwd)

TARGET_AUTO_KDIR := $(shell echo $(TARGET_DEVICE_DIR) | sed -e 's/^device/kernel/g')
TARGET_KERNEL_SOURCE ?= $(TARGET_AUTO_KDIR)
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_KERNEL_SOURCE :=
endif

TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
ifeq ($(TARGET_KERNEL_ARCH),)
KERNEL_ARCH := $(TARGET_ARCH)
else
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
endif

TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(strip $(TARGET_KERNEL_CROSS_COMPILE_PREFIX))
ifneq ($(TARGET_KERNEL_CROSS_COMPILE_PREFIX),)
KERNEL_TOOLCHAIN_PREFIX ?= $(TARGET_KERNEL_CROSS_COMPILE_PREFIX)
else ifeq ($(KERNEL_ARCH),arm64)
ifeq ($(TARGET_KERNEL_CLANG_COMPILE),true)
    KERNEL_TOOLCHAIN_PREFIX ?= aarch64-linux-android-
else
    KERNEL_TOOLCHAIN_PREFIX ?= aarch64-linux-androidkernel-
endif
else ifeq ($(KERNEL_ARCH),arm)
KERNEL_TOOLCHAIN_PREFIX ?= arm-linux-androidkernel-
else ifeq ($(KERNEL_ARCH),x86)
KERNEL_TOOLCHAIN_PREFIX ?= x86_64-linux-androidkernel-
endif

ifeq ($(KERNEL_TOOLCHAIN),)
KERNEL_TOOLCHAIN_PATH := $(KERNEL_TOOLCHAIN_PREFIX)
else ifneq ($(KERNEL_TOOLCHAIN_PREFIX),)
KERNEL_TOOLCHAIN_PATH := $(KERNEL_TOOLCHAIN)/$(KERNEL_TOOLCHAIN_PREFIX)
endif

ifneq ($(USE_CCACHE),)
    # Detect if the system already has ccache installed to use instead of the prebuilt
    CCACHE_BIN := $(shell which ccache)

    ifeq ($(CCACHE_BIN),)
        CCACHE_BIN := $(BUILD_TOP)/prebuilts/misc/$(HOST_PREBUILT_TAG)/ccache/ccache
        # Check that the executable is here.
        CCACHE_BIN := $(strip $(wildcard $(CCACHE_BIN)))
    endif
endif

ifeq ($(TARGET_KERNEL_CLANG_COMPILE),true)
    KERNEL_CROSS_COMPILE := CROSS_COMPILE="$(KERNEL_TOOLCHAIN_PATH)"
else
    KERNEL_CROSS_COMPILE := CROSS_COMPILE="$(CCACHE_BIN) $(KERNEL_TOOLCHAIN_PATH)"
endif

# Needed for CONFIG_COMPAT_VDSO, safe to set for all arm64 builds
ifeq ($(KERNEL_ARCH),arm64)
   KERNEL_CROSS_COMPILE += CROSS_COMPILE_ARM32="arm-linux-androideabi-"
endif

# Clear this first to prevent accidental poisoning from env
KERNEL_MAKE_FLAGS :=

# Add back threads, ninja cuts this to $(nproc)/2
KERNEL_MAKE_FLAGS += -j$$(nproc)

ifeq ($(KERNEL_ARCH),arm)
  # Avoid "Unknown symbol _GLOBAL_OFFSET_TABLE_" errors
  KERNEL_MAKE_FLAGS += CFLAGS_MODULE="-fno-pic"
endif

ifeq ($(KERNEL_ARCH),arm64)
  # Avoid "unsupported RELA relocation: 311" errors (R_AARCH64_ADR_GOT_PAGE)
  KERNEL_MAKE_FLAGS += CFLAGS_MODULE="-fno-pic"
endif

ifeq ($(HOST_OS),darwin)
  KERNEL_MAKE_FLAGS += C_INCLUDE_PATH=$(BUILD_TOP)/external/elfutils/libelf:/usr/local/opt/openssl/include
  KERNEL_MAKE_FLAGS += LIBRARY_PATH=/usr/local/opt/openssl/lib
endif

ifneq ($(TARGET_KERNEL_ADDITIONAL_FLAGS),)
  KERNEL_MAKE_FLAGS += $(TARGET_KERNEL_ADDITIONAL_FLAGS)
endif

# Set DTBO image locations so the build system knows to build them
ifeq ($(TARGET_NEEDS_DTBOIMAGE),true)
BOARD_PREBUILT_DTBOIMAGE ?= $(PRODUCT_OUT)/dtbo/arch/$(KERNEL_ARCH)/boot/dtbo.img
else ifeq ($(BOARD_KERNEL_SEPARATED_DTBO),true)
BOARD_PREBUILT_DTBOIMAGE ?= $(PRODUCT_OUT)/dtbo-pre.img
endif

# Set use the full path to the make command
KERNEL_MAKE_CMD := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_OS)-x86/bin/make

# Set the full path to the gcc command
GCC_PREBUILTS := $(BUILD_TOP)/prebuilts/gcc/$(HOST_OS)-x86/host
ifeq ($(HOST_OS),darwin)
KERNEL_HOST_TOOLCHAIN_ROOT := $(GCC_PREBUILTS)/i686-apple-darwin-4.2.1/bin/i686-apple-darwin11-
else
KERNEL_HOST_TOOLCHAIN_ROOT := $(GCC_PREBUILTS)/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-
endif
KERNEL_MAKE_FLAGS += HOSTCC=$(KERNEL_HOST_TOOLCHAIN_ROOT)gcc
KERNEL_MAKE_FLAGS += HOSTCXX=$(KERNEL_HOST_TOOLCHAIN_ROOT)g++
