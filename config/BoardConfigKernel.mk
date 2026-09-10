# Copyright (C) 2018-2024 The LineageOS Project
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
#   TARGET_KERNEL_ARCH                 = Kernel Arch
#
#   TARGET_KERNEL_CLANG_VERSION        = Clang prebuilts version, optional, defaults to clang-stable
#   TARGET_KERNEL_CLANG_PATH           = Clang prebuilts path, optional
#
#   TARGET_KERNEL_LIBC_SYSROOT_USE     = libc sysroot to use, defaults to "host" for 6.11+
#
#   TARGET_KERNEL_RUST_VERSION         = Rust prebuilts version, optional
#   TARGET_KERNEL_VERSION              = Reported kernel version in top level kernel
#                                        makefile. Can be overriden in device trees
#                                        in the event of prebuilt kernel.
#
#   TARGET_KERNEL_DTBO_PREFIX          = Override path prefix of TARGET_KERNEL_DTBO.
#                                        Defaults to empty
#   TARGET_KERNEL_DTBO                 = Name of the kernel Makefile target that
#                                        generates dtbo.img. Defaults to dtbo.img
#   TARGET_KERNEL_DTB                  = Name of the kernel Makefile target that
#                                        generates the *.dtb targets. Defaults to dtbs
#
#   TARGET_KERNEL_EXT_MODULE_ROOT      = Optional, the external modules root directory
#                                          Defaults to empty
#   TARGET_KERNEL_EXT_MODULES          = Optional, the external modules we are
#                                          building. Defaults to empty
#
#   USE_CCACHE                         = Enable ccache (global Android flag)
#   USE_RBE                            = Enable RBE (global Android flag)

include vendor/lineage/build/core/utils.mk

BUILD_TOP := $(abspath .)

TARGET_AUTO_KDIR := $(shell echo $(TARGET_DEVICE_DIR) | sed -e 's/^device/kernel/g')
TARGET_KERNEL_SOURCE ?= $(TARGET_AUTO_KDIR)

TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
ifeq ($(TARGET_KERNEL_ARCH),)
    KERNEL_ARCH := $(TARGET_ARCH)
else
    KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
endif

ifeq ($(KERNEL_ARCH),arm64)
KERNEL_GKI_ARCH := aarch64
else
KERNEL_GKI_ARCH ?= $(KERNEL_ARCH)
endif
KERNEL_GKI_ARCH_DIR_PATH := $(TARGET_KERNEL_SOURCE)/gki/$(KERNEL_GKI_ARCH)

KERNEL_VERSION := $(shell grep -s "^VERSION = " $(TARGET_KERNEL_SOURCE)/Makefile | awk '{ print $$3 }')
KERNEL_PATCHLEVEL := $(shell grep -s "^PATCHLEVEL = " $(TARGET_KERNEL_SOURCE)/Makefile | awk '{ print $$3 }')
TARGET_KERNEL_VERSION ?= $(shell echo $(KERNEL_VERSION)"."$(KERNEL_PATCHLEVEL))

# 6.11+ can no longer use aosp glibc sysroot headers (too old)
ifneq ($(KERNEL_VERSION),)
    ifeq ($(call is-version-greater-or-equal,$(TARGET_KERNEL_VERSION),6.11),true)
        TARGET_KERNEL_LIBC_SYSROOT_USE ?= host
    endif
endif

ifneq ($(TARGET_KERNEL_CLANG_VERSION),)
    KERNEL_CLANG_VERSION := clang-$(TARGET_KERNEL_CLANG_VERSION)
else
    # Use the default version of clang if TARGET_KERNEL_CLANG_VERSION hasn't been set by the device config
    KERNEL_CLANG_VERSION := $(LLVM_AOSP_PREBUILTS_VERSION)
endif
TARGET_KERNEL_CLANG_PATH ?= $(BUILD_TOP)/prebuilts/clang/host/$(HOST_PREBUILT_TAG)/$(KERNEL_CLANG_VERSION)

TARGET_KERNEL_RUST_VERSION ?= $(RUST_AOSP_PREBUILTS_VERSION)

ifneq ($(USE_CCACHE),)
    ifneq ($(CCACHE_EXEC),)
        # Android 10+ deprecates use of a build ccache. Only system installed ones are now allowed
        CCACHE_BIN := $(CCACHE_EXEC)
    endif
endif

# build/make/core/rbe.mk is only read while dumping the product config, so the
# rewrapper flags have to be recreated here
KERNEL_RBE_WRAPPER :=
ifneq ($(filter-out false,$(USE_REWRAPPER)),)
    # An out dir outside of the tree can't be a remote input or output
    ifneq ($(filter $(BUILD_TOP)/%,$(abspath $(OUT_DIR))),)
        KERNEL_RBE_WRAPPER := $(abspath $(if $(RBE_DIR),$(RBE_DIR),prebuilts/remoteexecution-client/live))/rewrapper
        KERNEL_RBE_WRAPPER += --labels=type=compile,lang=cpp,compiler=clang
        KERNEL_RBE_WRAPPER += --env_var_allowlist=PWD
        KERNEL_RBE_WRAPPER += --exec_strategy=$(if $(RBE_CXX_EXEC_STRATEGY),$(RBE_CXX_EXEC_STRATEGY),local)
        KERNEL_RBE_WRAPPER += --compare=$(if $(RBE_CXX_COMPARE),$(RBE_CXX_COMPARE),false)
        ifneq ($(RBE_platform),)
            KERNEL_RBE_WRAPPER += --platform=$(RBE_platform),Pool=$(if $(RBE_CXX_POOL),$(RBE_CXX_POOL),default)
        endif
    endif
endif

# ccache can't cache anything behind another wrapper, so it gives way to RBE
ifneq ($(KERNEL_RBE_WRAPPER),)
    KERNEL_CC_WRAPPER := $(BUILD_TOP)/vendor/lineage/build/tools/kernel_rbe_cc.sh
else
    KERNEL_CC_WRAPPER := $(CCACHE_BIN)
endif

# Clear this first to prevent accidental poisoning from env
KERNEL_MAKE_FLAGS :=

# Add back threads, ninja cuts this to $(getconf _NPROCESSORS_ONLN)/2
KERNEL_MAKE_FLAGS += -j$(shell getconf _NPROCESSORS_ONLN)

TOOLS_PATH_OVERRIDE := \
    HIP_PATH=none PERL5LIB=$(BUILD_TOP)/prebuilts/tools-lineage/common/perl-base

ifeq ($(TARGET_KERNEL_LIBC_SYSROOT_USE), host)
    KERNEL_HOST_C_LD_FLAGS_SYSROOT :=
else
    KERNEL_HOST_C_LD_FLAGS_SYSROOT := --sysroot=$(BUILD_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/sysroot
endif

KERNEL_MAKE_FLAGS += HOSTCFLAGS="$(KERNEL_HOST_C_LD_FLAGS_SYSROOT) -I$(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/include"
KERNEL_MAKE_FLAGS += HOSTLDFLAGS="$(KERNEL_HOST_C_LD_FLAGS_SYSROOT) -Wl,-rpath,$(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/lib64 -L $(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/lib64 -fuse-ld=lld --rtlib=compiler-rt"

TOOLS_PATH_OVERRIDE += PATH=$(BUILD_TOP)/prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin:$(TARGET_KERNEL_CLANG_PATH)/bin:$(BUILD_TOP)/prebuilts/rust-toolchain/$(HOST_PREBUILT_TAG)/$(TARGET_KERNEL_RUST_VERSION)/bin:$(BUILD_TOP)/prebuilts/clang-tools/$(HOST_PREBUILT_TAG)/bin:$$PATH

# Set DTBO image locations so the build system knows to build them
ifneq (,$(filter true, $(TARGET_NEEDS_DTBOIMAGE) $(BOARD_KERNEL_SEPARATED_DTBO)))
    TARGET_KERNEL_DTBO_PREFIX ?=
    TARGET_KERNEL_DTBO ?= dtbo.img
    BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_OUT_INTERMEDIATES)/DTBO_OBJ/arch/$(KERNEL_ARCH)/boot/$(TARGET_KERNEL_DTBO_PREFIX)$(TARGET_KERNEL_DTBO)
endif

# Set the default dtb target
TARGET_KERNEL_DTB ?= dtbs

# Set no external modules by default
TARGET_KERNEL_EXT_MODULE_ROOT ?=
TARGET_KERNEL_EXT_MODULES ?=

# Set use the full path to the make command
KERNEL_MAKE_CMD := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/make

# Use LLVM's substitutes for GNU binutils
KERNEL_MAKE_FLAGS += LLVM=1 LLVM_IAS=1

# Pass prebuilt LZ4 path
KERNEL_MAKE_FLAGS += LZ4=$(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/bin/lz4

# Since Linux 4.16, flex and bison are required
KERNEL_MAKE_FLAGS += LEX=$(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/flex
KERNEL_MAKE_FLAGS += YACC=$(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/bison
KERNEL_MAKE_FLAGS += M4=$(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/m4
TOOLS_PATH_OVERRIDE += BISON_PKGDATADIR=$(BUILD_TOP)/prebuilts/build-tools/common/bison

# Since Linux 5.10, pahole is required
KERNEL_MAKE_FLAGS += PAHOLE=$(BUILD_TOP)/prebuilts/kernel-build-tools/linux-x86/bin/pahole

# Rust bindgen wants matching Clang and libclang versions
KERNEL_MAKE_FLAGS += LIBCLANG_PATH=$(TARGET_KERNEL_CLANG_PATH)/lib

# AutoFDO
# Ideally, we also want to detect 'CONFIG_AUTOFDO_CLANG=y' from kernel configs...
# Note: The path `toolchain/pgo-profiles/kernel` contains AutoFDO profiles too
ifneq ($(TARGET_KERNEL_CLANG_AUTOFDO_PROFILE),none)
    TARGET_KERNEL_CLANG_AUTOFDO_PROFILE ?= $(KERNEL_GKI_ARCH_DIR_PATH)/afdo/kernel.afdo
    ifneq ($(wildcard $(TARGET_KERNEL_CLANG_AUTOFDO_PROFILE)),)
        KERNEL_MAKE_FLAGS += CLANG_AUTOFDO_PROFILE=$(BUILD_TOP)/$(TARGET_KERNEL_CLANG_AUTOFDO_PROFILE)
    endif
endif

# Set the out dir for the kernel's O= arg
# This needs to be an absolute path, so only set this if the standard out dir isn't used
OUT_DIR_PREFIX := $(shell echo $(OUT_DIR) | sed -e 's|/target/.*$$||g')
KERNEL_BUILD_OUT_PREFIX :=
ifeq ($(OUT_DIR_PREFIX),out)
    KERNEL_BUILD_OUT_PREFIX := $(BUILD_TOP)/
endif

ifneq ($(TARGET_KERNEL_PLATFORM_TARGET),)
KERNEL_PATH := $(abspath $(BUILD_TOP)/kernel/platform/kernel-$(TARGET_KERNEL_VERSION))
endif
