# Copyright (C) 2012 The CyanogenMod Project
#           (C) 2017-2025 The LineageOS Project
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


# Android makefile to build kernel as a part of Android Build
#
# Configuration
# =============
#
# These config vars are usually set in BoardConfig.mk:
#
#   TARGET_KERNEL_ADDITIONAL_FLAGS     = Additional make flags, optional
#   TARGET_KERNEL_CONFIG               = List of kernel defconfigs, first one being the base one,
#                                          while all the others are fragments that will be merged
#                                          to main one in .config.
#   TARGET_KERNEL_CONFIG_EXT           = List of path to external kernel defconfigs.
#                                          Same as TARGET_KERNEL_CONFIG, but paths are specified
#                                          instead of filenames.
#
#   TARGET_KERNEL_CLANG_COMPILE        = Compile kernel with clang, defaults to true
#
#   BOARD_KERNEL_IMAGE_NAME            = Built image name
#                                          for ARM use: zImage
#                                          for ARM64 use: Image.gz
#                                          for x86 use: bzImage
#                                          for uncompressed use: Image
#                                          If using an appended DT, append '-dtb'
#                                          to the end of the image name.
#                                          For example, for ARM devices,
#                                          use zImage-dtb instead of zImage.
#
#   BOARD_KERNEL_APPEND_DTBS           = List of DTBs to be appended to the kernel image,
#                                          wildcard is allowed for filename.
#
#   BOARD_DTB_CFG                      = Path to a mkdtboimg config file for dtb.img
#
#   BOARD_DTBO_CFG                     = Path to a mkdtboimg config file
#
#   BOARD_CUSTOM_DTBIMG_MK             = Path to a custom dtbimage makefile
#
#   BOARD_CUSTOM_DTBOIMG_MK            = Path to a custom dtboimage makefile
#
#   KERNEL_CC                          = The C Compiler used. This is automatically set based
#                                          on whether the clang version is set, optional.
#
#   KERNEL_CLANG_TRIPLE                = Target triple for clang (e.g. aarch64-linux-gnu-)
#                                          defaults to arm-linux-gnu- for arm
#                                                      aarch64-linux-gnu- for arm64
#                                                      x86_64-linux-gnu- for x86
#
#   KERNEL_LTO                         = Optional, force LTO to none / thin / full
#
#   MERGE_ALL_KERNEL_CONFIGS_AT_ONCE   = Optional, whether or not to merge all kernel config
#                                          fragments in one merge_configs.sh call. if true,
#                                          kernel config fragments will get merged faster, but
#                                          may cause some differences.
#
#   NEED_KERNEL_MODULE_ROOT            = Optional, if true, install kernel
#                                          modules in root instead of vendor
#   NEED_KERNEL_MODULE_SYSTEM          = Optional, if true, install kernel
#                                          modules in system instead of vendor
#   NEED_KERNEL_MODULE_VENDOR_OVERLAY  = Optional, if true, install kernel
#                                          modules in vendor_overlay instead of vendor
#
#   TARGET_FORCE_PREBUILT_KERNEL       = Optional, use TARGET_PREBUILT_KERNEL even if
#                                          kernel sources are present
#   TARGET_PREBUILT_KERNEL_HEADERS     = Optional, if this is set, don't warn about prebuilt
#                                          kernel because headers should match
#
#   TARGET_MERGE_DTBS_WILDCARD         = Optional, limits the .dtb files used to generate the
#                                          final DTB image when using QCOM's merge_dtbs script.
#   TARGET_DTB_LIST_WILDCARD           = Optional, limits the .dtb files used to generate the
#                                          final DTB image when NOT using QCOM's merge_dtbs
#                                          script. Allows multiple patterns.
#
#   TARGET_KERNEL_PLATFORM_TARGET      = Optional, enables building an external kernel
#                                          platform tree, this specifies the base target name

ifneq ($(TARGET_NO_KERNEL),true)
ifneq ($(TARGET_NO_KERNEL_OVERRIDE),true)

## Externally influenced variables
KERNEL_SRC := $(TARGET_KERNEL_SOURCE)
ifneq ($(BOARD_SYSTEM_KERNEL_MODULES_LOAD),false)
SYSTEM_KERNEL_MODULES_LOAD := $(BOARD_SYSTEM_KERNEL_MODULES_LOAD)
endif
# kernel configuration - mandatory
MERGE_ALL_KERNEL_CONFIGS_AT_ONCE ?= false
KERNEL_DEFCONFIG := $(TARGET_KERNEL_CONFIG)
KERNEL_DEFCONFIG_EXT := $(TARGET_KERNEL_CONFIG_EXT)
# dtb generation - optional
TARGET_MERGE_DTBS_WILDCARD ?= *
TARGET_DTB_LIST_WILDCARD ?= *
# recovery modules.load fallback - optional
BOARD_RECOVERY_KERNEL_MODULES_LOAD ?= $(BOARD_RECOVERY_RAMDISK_KERNEL_MODULES_LOAD)
TARGET_KERNEL_MIXED_MODE ?= true

## Internal variables
DTC := $(HOST_OUT_EXECUTABLES)/dtc
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
DTBO_OUT := $(TARGET_OUT_INTERMEDIATES)/DTBO_OBJ
DTB_OUT := $(TARGET_OUT_INTERMEDIATES)/DTB_OBJ
ifeq ($(BOARD_USES_QCOM_MERGE_DTBS_SCRIPT),true)
DTBS_BASE := $(DTB_OUT)/base
DTBS_OUT := $(DTB_OUT)/out
endif
KERNEL_CONFIG := $(KERNEL_OUT)/.config
KERNEL_RELEASE := $(KERNEL_OUT)/include/config/kernel.release
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
ifeq ($(call is-version-greater-or-equal,$(TARGET_KERNEL_VERSION),5.15),true)
ifeq ($(call is-version-lower-or-equal,$(TARGET_KERNEL_VERSION),6.1),true)
GKI_SUFFIX := /$(shell echo android$(PLATFORM_VERSION)-$(TARGET_KERNEL_VERSION))
endif
endif
endif

ifeq ($(KERNEL_ARCH),x86_64)
KERNEL_DEFCONFIG_ARCH := x86
else
KERNEL_DEFCONFIG_ARCH := $(KERNEL_ARCH)
endif
KERNEL_DEFCONFIG_DIR := $(KERNEL_SRC)/arch/$(KERNEL_DEFCONFIG_ARCH)/configs

ALL_KERNEL_DEFCONFIG_SRCS := $(foreach config,$(KERNEL_DEFCONFIG),$(KERNEL_DEFCONFIG_DIR)/$(config))
ALL_KERNEL_DEFCONFIG_SRCS += $(KERNEL_DEFCONFIG_EXT)

BASE_KERNEL_DEFCONFIG_SRC := $(word 1, $(ALL_KERNEL_DEFCONFIG_SRCS))

ifeq ($(TARGET_PREBUILT_KERNEL),)
    ifeq ($(BOARD_KERNEL_IMAGE_NAME),)
        $(error BOARD_KERNEL_IMAGE_NAME not defined.)
    endif
endif
TARGET_PREBUILT_INT_KERNEL := $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME)

ifeq "$(wildcard $(KERNEL_SRC) )" ""
    ifneq ($(TARGET_PREBUILT_KERNEL),)
        HAS_PREBUILT_KERNEL := true
        NEEDS_KERNEL_COPY := true
    else
        $(foreach cf,$(PRODUCT_COPY_FILES), \
            $(eval _src := $(call word-colon,1,$(cf))) \
            $(eval _dest := $(call word-colon,2,$(cf))) \
            $(ifeq kernel,$(_dest), \
                $(eval HAS_PREBUILT_KERNEL := true)))
    endif

    ifneq ($(TARGET_KERNEL_PLATFORM_TARGET),)
        ifeq "$(wildcard $(abspath $(BUILD_TOP)/../kernel-$(TARGET_KERNEL_VERSION))/$(KERNEL_SRC) )" ""
            $(warning ***************************************************************)
            $(warning *                                                             *)
            $(warning * No kernel platform source found.                            *)
            $(warning * Please make sure your device is properly configured to      *)
            $(warning * download the kernel repository to $(KERNEL_SRC))
            $(warning *                                                             *)
            $(warning ***************************************************************)
            $(error "NO KERNEL")
        endif
        NEEDS_KERNEL_COPY := true
        FULL_KERNEL_BUILD := false
        TARGET_PREBUILT_INT_KERNEL := $(KERNEL_OUT)/$(BOARD_KERNEL_IMAGE_NAME)
        KERNEL_BIN := $(TARGET_PREBUILT_INT_KERNEL)
    else ifneq ($(HAS_PREBUILT_KERNEL),)
        ifeq ($(TARGET_PREBUILT_KERNEL_HEADERS),)
            $(warning ***************************************************************)
            $(warning * Using prebuilt kernel binary instead of source              *)
            $(warning * THIS IS DEPRECATED, AND IS NOT ADVISED.                     *)
            $(warning * Please configure your device to download the kernel         *)
            $(warning * source repository to $(KERNEL_SRC))
            $(warning * for more information                                        *)
            $(warning ***************************************************************)
        endif
        FULL_KERNEL_BUILD := false
        KERNEL_BIN := $(TARGET_PREBUILT_KERNEL)
    else
        $(warning ***************************************************************)
        $(warning *                                                             *)
        $(warning * No kernel source found, and no fallback prebuilt defined.   *)
        $(warning * Please make sure your device is properly configured to      *)
        $(warning * download the kernel repository to $(KERNEL_SRC))
        $(warning * and add the TARGET_KERNEL_CONFIG variable to BoardConfig.mk *)
        $(warning *                                                             *)
        $(warning * As an alternative, define the TARGET_PREBUILT_KERNEL        *)
        $(warning * variable with the path to the prebuilt binary kernel image  *)
        $(warning * in your BoardConfig.mk file                                 *)
        $(warning *                                                             *)
        $(warning ***************************************************************)
        $(error "NO KERNEL")
    endif
else
    NEEDS_KERNEL_COPY := true
    ifeq ($(TARGET_KERNEL_CONFIG)$(TARGET_KERNEL_CONFIG_EXT),)
        $(warning **********************************************************)
        $(warning * Kernel source found, but no configuration was defined  *)
        $(warning * Please add the TARGET_KERNEL_CONFIG variable to your   *)
        $(warning * BoardConfig.mk file                                    *)
        $(warning **********************************************************)
        $(error "NO KERNEL CONFIG")
    else
        ifneq ($(TARGET_FORCE_PREBUILT_KERNEL),)
            ifneq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(LINEAGE_BUILDTYPE)),)
                $(error "PREBUILT KERNEL IS NOT ALLOWED ON OFFICIAL BUILDS!")
            else
                $(warning **********************************************************)
                $(warning * Kernel source found and configuration was defined,     *)
                $(warning * but prebuilt kernel is being forced.                   *)
                $(warning * While this is likely intentional,                      *)
                $(warning * it is NOT SUPPORTED WHATSOEVER.                        *)
                $(warning * Generated kernel headers may not align with            *)
                $(warning * the ABI of kernel you're including.                    *)
                $(warning * Please unset TARGET_FORCE_PREBUILT_KERNEL              *)
                $(warning * to build the kernel from source.                       *)
                $(warning **********************************************************)
                FULL_KERNEL_BUILD := false
                KERNEL_BIN := $(TARGET_PREBUILT_KERNEL)
            endif
        else
            FULL_KERNEL_BUILD := true
            KERNEL_BIN := $(TARGET_PREBUILT_INT_KERNEL)
        endif
    endif
endif

ifeq ($(FULL_KERNEL_BUILD),true)
# Add host bin out dir to path
PATH_OVERRIDE := PATH=$(KERNEL_BUILD_OUT_PREFIX)$(HOST_OUT_EXECUTABLES):$$PATH
ifneq ($(TARGET_KERNEL_CLANG_COMPILE),false)
    ifneq ($(KERNEL_NO_GCC), true)
        ifeq ($(KERNEL_ARCH),arm64)
            KERNEL_CLANG_TRIPLE ?= CLANG_TRIPLE=aarch64-linux-gnu-
        else ifeq ($(KERNEL_ARCH),arm)
            KERNEL_CLANG_TRIPLE ?= CLANG_TRIPLE=arm-linux-gnu-
        else ifeq ($(KERNEL_ARCH),x86)
            KERNEL_CLANG_TRIPLE ?= CLANG_TRIPLE=x86_64-linux-gnu-
        endif
        PATH_OVERRIDE += LD_LIBRARY_PATH=$(TARGET_KERNEL_CLANG_PATH)/lib64:$$LD_LIBRARY_PATH
    endif
    PATH_OVERRIDE += PATH=$(TARGET_KERNEL_CLANG_PATH)/bin:$$PATH
    ifeq ($(KERNEL_CC),)
        KERNEL_CC := CC="$(CCACHE_BIN) clang" LD=ld.lld
    endif
endif

ifneq ($(KERNEL_NO_GCC), true)
    PATH_OVERRIDE += PATH=$(KERNEL_TOOLCHAIN_PATH_gcc):$$PATH
endif

# System tools are no longer allowed on 10+
PATH_OVERRIDE += $(TOOLS_PATH_OVERRIDE)

ifeq (true,$(filter true, $(TARGET_NEEDS_DTBOIMAGE) $(BOARD_KERNEL_SEPARATED_DTBO)))
    KERNEL_MAKE_FLAGS += DTC_EXT=$(KERNEL_BUILD_OUT_PREFIX)$(DTC)
endif

ifneq ($(TARGET_KERNEL_ADDITIONAL_FLAGS),)
    KERNEL_MAKE_FLAGS += $(TARGET_KERNEL_ADDITIONAL_FLAGS)
endif

# Internal implementation of make-kernel-target
# $(1): output path (The value passed to O=)
# $(2): target to build (eg. defconfig, modules, dtbo.img)
define internal-make-kernel-target
$(PATH_OVERRIDE) $(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_BUILD_OUT_PREFIX)$(1) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(KERNEL_CLANG_TRIPLE) $(KERNEL_CC) $(2)
endef

# Make an external module target
# $(1): module name
# $(2): module root path
# $(3): target to build (eg. modules_install)
define make-external-module-target
$(PATH_OVERRIDE) $(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(TARGET_KERNEL_EXT_MODULE_ROOT)/$(1) M=$(2)/$(1) KERNEL_SRC=$(BUILD_TOP)/$(KERNEL_SRC) OUT_DIR=$(KERNEL_BUILD_OUT_PREFIX)$(KERNEL_OUT) O=$(KERNEL_BUILD_OUT_PREFIX)$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(KERNEL_CLANG_TRIPLE) $(KERNEL_CC) $(3)
endef

# Make an external module target using kbuild
# $(1): module name
# $(2): module root path relative to kernel source
# $(2): target to build (eg. modules_install)
define make-kbuild-module-target
$(PATH_OVERRIDE) $(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(BUILD_TOP)/$(KERNEL_SRC) M=$(2)/$(1) O=$(KERNEL_BUILD_OUT_PREFIX)$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(KERNEL_CLANG_TRIPLE) $(KERNEL_CC) $(3)
endef

# Generate kernel .config from a given defconfig
# $(1): Output path (The value passed to O=)
# $(2): The defconfig to process (full path to file)
define make-kernel-config
	cp $(word 1,$(2)) $(1)/.config; \
	$(call internal-make-kernel-target,$(1),olddefconfig); \
	$(if $(filter true,$(MERGE_ALL_KERNEL_CONFIGS_AT_ONCE)),\
		$(KERNEL_SRC)/scripts/kconfig/merge_config.sh -m -O $(1) $(1)/.config $(filter %.config,$(2)); \
		$(call internal-make-kernel-target,$(1),olddefconfig); \
	, \
		$(foreach config,$(filter %.config,$(2)), \
			$(KERNEL_SRC)/scripts/kconfig/merge_config.sh -m -O $(1) $(1)/.config $(config); \
			$(call internal-make-kernel-target,$(1),olddefconfig); \
		) \
	)
	$(hide) if [ "$(KERNEL_LTO)" = "none" ]; then \
			$(KERNEL_SRC)/scripts/config --file $(1)/.config \
			-d LTO_CLANG \
			-e LTO_NONE \
			-d LTO_CLANG_THIN \
			-d LTO_CLANG_FULL \
			-d THINLTO; \
			$(call make-kernel-target,olddefconfig); \
		elif [ "$(KERNEL_LTO)" = "thin" ]; then \
			$(KERNEL_SRC)/scripts/config --file $(1)/.config \
			-e LTO_CLANG \
			-d LTO_NONE \
			-e LTO_CLANG_THIN \
			-d LTO_CLANG_FULL \
			-e THINLTO; \
			$(call make-kernel-target,olddefconfig); \
		elif [ "$(KERNEL_LTO)" = "full" ]; then \
			$(KERNEL_SRC)/scripts/config --file $(1)/.config \
			-e LTO_CLANG \
			-d LTO_NONE \
			-d LTO_CLANG_THIN \
			-e LTO_CLANG_FULL \
			-d THINLTO; \
			$(call make-kernel-target,olddefconfig); \
		fi
	$(hide) if [ ! -z "$(KERNEL_CONFIG_OVERRIDE)" ]; then \
			echo "Overriding kernel config with '$(KERNEL_CONFIG_OVERRIDE)'"; \
			echo $(KERNEL_CONFIG_OVERRIDE) >> $(1)/.config; \
			$(call make-kernel-target,oldconfig); \
		fi
endef

# Make a kernel target
# $(1): The kernel target to build (eg. defconfig, modules, modules_install)
define make-kernel-target
$(call internal-make-kernel-target,$(KERNEL_OUT),$(1))
endef

# Make a DTBO target
# $(1): The DTBO target to build (eg. dtbo.img, defconfig)
define make-dtbo-target
$(call internal-make-kernel-target,$(DTBO_OUT),$(1))
endef

# Make a DTB targets
# $(1): The DTB target to build (eg. dtbs, defconfig)
define make-dtb-target
$(call internal-make-kernel-target,$(DTB_OUT),$(1))
endef

endif # FULL_KERNEL_BUILD

ifneq ($(filter $(FULL_KERNEL_BUILD),true)$(TARGET_KERNEL_PLATFORM_TARGET),)

# $(1): modules list
# $(2): output dir
# $(3): mount point
# $(4): staging dir
# $(5): module load list
# $(6): suffix for output dir, needed for GKI modules usecase, empty otherwise
# $(7): partition image intermediates file list
# $(8): external dependency module intermediates dir
# Depmod requires a well-formed kernel version so 0.0 is used as a placeholder.
define build-image-kernel-modules-lineage
    mkdir -p $(2)/lib/modules$(6)
    cp $(1) $(2)/lib/modules$(6)
    rm -rf $(4)
    mkdir -p $(4)/lib/modules/0.0/$(3)lib/modules$(6)
    cp $(1) $(4)/lib/modules/0.0/$(3)lib/modules$(6)
    if [ -n "$(8)" ]; then cp -r $(8) $(4)/lib/modules/0.0/; fi
    $(DEPMOD) -ae -F $(KERNEL_OUT)/System.map -b $(4) 0.0 2>$(4)/depmod_stderr
    cat $(4)/depmod_stderr >&2
    if { grep -q "needs unknown symbol" $(4)/depmod_stderr; }; then \
      echo "ERROR: kernel module(s) need unknown symbol(s)" >&2; \
      rm -f $(4)/depmod_stderr; \
      exit 1; \
    fi
    rm -f $(4)/depmod_stderr
    sed -e 's/\(.*modules.*\):/\/\1:/g' -e 's/ \([^ ]*modules[^ ]*\)/ \/\1/g' $(4)/lib/modules/0.0/modules.dep > $(2)/lib/modules$(6)/modules.dep
    cp $(4)/lib/modules/0.0/modules.softdep $(2)/lib/modules$(6)
    cp $(4)/lib/modules/0.0/modules.alias $(2)/lib/modules$(6)
    rm -f $(2)/lib/modules$(6)/modules.load
    for MODULE in $(5); do \
        NAME=$$(basename $$MODULE .ko); \
        if [ -n "$$(find $(2)/lib/modules$(6) -type f -name $$NAME'.ko')" ]; then \
            echo "$$NAME" >> $(2)/lib/modules$(6)/modules.load; \
        else \
            echo "ERROR: $$NAME.ko was not found in the kernel modules intermediates dir, module load list must be corrected" 1>&2; \
            ERROR=1; \
        fi; \
    done; \
    if [ -n "$$ERROR" ]; then \
        exit 1; \
    fi; \
    if [ -n "$(7)" ]; then \
        echo lib/modules$(6)/modules.alias >> "$(7)"; \
        echo lib/modules$(6)/modules.dep >> "$(7)"; \
        if [ ! -z "$(5)" ]; then echo lib/modules$(6)/modules.load >> "$(7)"; fi; \
        echo lib/modules$(6)/modules.softdep >> "$(7)"; \
        for MODULE in $(1); do \
            BASENAME=$$(basename $$MODULE); \
            echo lib/modules$(6)/"$$BASENAME" >> "$(7)"; \
        done; \
        sort -u "$(7)" -o "$(7)"; \
    fi;
endef

endif # FULL_KERNEL_BUILD or TARGET_KERNEL_PLATFORM_TARGET

ifneq ($(filter $(FULL_KERNEL_BUILD),true)$(TARGET_KERNEL_PLATFORM_TARGET),)

ifeq ($(NEED_KERNEL_MODULE_ROOT),true)
KERNEL_MODULES_OUT := $(TARGET_ROOT_OUT)
KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_recovery)
KERNEL_MODULE_MOUNTPOINT :=
else ifeq ($(NEED_KERNEL_MODULE_SYSTEM),true)
KERNEL_MODULES_OUT := $(TARGET_OUT)
KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_system)
KERNEL_MODULE_MOUNTPOINT := system
$(INSTALLED_SYSTEMIMAGE_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else ifeq ($(NEED_KERNEL_MODULE_VENDOR_OVERLAY),true)
KERNEL_MODULES_OUT := $(TARGET_OUT_PRODUCT)/vendor_overlay/$(PRODUCT_TARGET_VNDK_VERSION)
KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_product)
KERNEL_MODULE_MOUNTPOINT := vendor
$(INSTALLED_PRODUCTIMAGE_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else ifeq ($(BOARD_USES_VENDOR_DLKMIMAGE),true)
KERNEL_MODULES_OUT := $(TARGET_OUT_VENDOR_DLKM)
KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_vendor)
KERNEL_MODULE_MOUNTPOINT := vendor_dlkm
KERNEL_MODULES_PARTITION_FILE_LIST := $(vendor_dlkmimage_intermediates)/file_list.txt
$(INSTALLED_VENDOR_DLKMIMAGE_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else
KERNEL_MODULES_OUT := $(TARGET_OUT_VENDOR)
KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_vendor)
KERNEL_MODULE_MOUNTPOINT := vendor
ifneq ($(BUILDING_VENDOR_IMAGE),)
KERNEL_MODULES_PARTITION_FILE_LIST := $(vendorimage_intermediates)/file_list.txt
else # No vendor partition
KERNEL_MODULES_PARTITION_FILE_LIST := $(systemimage_intermediates)/file_list.txt
endif # BUILDING_VENDOR_IMAGE
$(INSTALLED_VENDORIMAGE_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
endif
ifeq ($(BOARD_USES_SYSTEM_DLKMIMAGE),true)
SYSTEM_KERNEL_MODULES_OUT := $(TARGET_OUT_SYSTEM_DLKM)
SYSTEM_KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_system_dlkm)
SYSTEM_KERNEL_MODULE_MOUNTPOINT := system_dlkm
SYSTEM_KERNEL_MODULES_PARTITION_FILE_LIST := $(system_dlkmimage_intermediates)/file_list.txt
$(INSTALLED_SYSTEM_DLKMIMAGE_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else ifneq ($(SYSTEM_KERNEL_MODULES)$(filter $(TARGET_KERNEL_MIXED_MODE),true),)
SYSTEM_KERNEL_MODULES_OUT := $(TARGET_OUT)
SYSTEM_KERNEL_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_system)
SYSTEM_KERNEL_MODULE_MOUNTPOINT := system
SYSTEM_KERNEL_MODULES_PARTITION_FILE_LIST := $(systemimage_intermediates)/file_list.txt
$(INSTALLED_SYSTEMIMAGE_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
endif
MODULES_INTERMEDIATES := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,kernel_modules)

ifneq (,$(filter dlkm,$(BOARD_VENDOR_RAMDISK_FRAGMENTS)))
KERNEL_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)
KERNEL_VENDOR_RAMDISK_MODULES_OUT := $(VENDOR_RAMDISK_FRAGMENT.dlkm.STAGING_DIR)
KERNEL_VENDOR_RAMDISK_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_vendor_ramdisk_fragment-stage-dlkm)
$(INTERNAL_VENDOR_RAMDISK_FRAGMENT_TARGETS): $(TARGET_PREBUILT_INT_KERNEL)
$(INTERNAL_VENDOR_RAMDISK_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else ifeq ($(PRODUCT_BUILD_VENDOR_KERNEL_BOOT_IMAGE),true)
KERNEL_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD)
KERNEL_VENDOR_RAMDISK_MODULES_OUT := $(TARGET_VENDOR_KERNEL_RAMDISK_OUT)
KERNEL_VENDOR_RAMDISK_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_vendor_kernel_ramdisk)
$(INTERNAL_VENDOR_KERNEL_RAMDISK_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
$(INTERNAL_VENDOR_RAMDISK_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else ifeq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
KERNEL_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)
KERNEL_VENDOR_RAMDISK_MODULES_OUT := $(TARGET_VENDOR_RAMDISK_OUT)
KERNEL_VENDOR_RAMDISK_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_vendor_ramdisk)
$(INTERNAL_VENDOR_RAMDISK_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
else
KERNEL_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)
KERNEL_VENDOR_RAMDISK_MODULES_OUT := $(TARGET_RAMDISK_OUT)
KERNEL_VENDOR_RAMDISK_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_ramdisk)
$(INSTALLED_RAMDISK_TARGET): $(TARGET_PREBUILT_INT_KERNEL)
endif

ifneq ($(RECOVERY_KERNEL_MODULES),)
KERNEL_RECOVERY_DEPMOD_STAGING_DIR := $(KERNEL_BUILD_OUT_PREFIX)$(call intermediates-dir-for,PACKAGING,depmod_recovery)
KERNEL_RECOVERY_MODULES_OUT := $(TARGET_RECOVERY_ROOT_OUT)
$(recovery_uncompressed_ramdisk): $(TARGET_PREBUILT_INT_KERNEL)
endif

endif # TARGET_KERNEL_PLATFORM_TARGET or FULL_KERNEL_BUILD

ifeq ($(FULL_KERNEL_BUILD),true)

$(KERNEL_OUT):
	mkdir -p $(KERNEL_OUT)

$(KERNEL_CONFIG): $(KERNEL_OUT) $(ALL_KERNEL_DEFCONFIG_SRCS)
	@echo "Building Kernel Config"
	$(call make-kernel-config,$(KERNEL_OUT),$(ALL_KERNEL_DEFCONFIG_SRCS))

$(TARGET_PREBUILT_INT_KERNEL): $(KERNEL_CONFIG) $(DEPMOD) $(DTC) $(KERNEL_MODULES_PARTITION_FILE_LIST) $(SYSTEM_KERNEL_MODULES_PARTITION_FILE_LIST)
	@echo "Building Kernel Image ($(BOARD_KERNEL_IMAGE_NAME))"
	$(call make-kernel-target,$(BOARD_KERNEL_IMAGE_NAME))
	$(hide) if [ -d "$(KERNEL_SRC)/arch/$(KERNEL_ARCH)/boot/dts/" ]; then \
			echo "Building DTBs"; \
			$(call make-kernel-target,dtbs); \
		fi
	$(hide) if grep -q '=m' $(KERNEL_CONFIG); then \
			echo "Building Kernel Modules"; \
			$(call make-kernel-target,modules) || exit "$$?"; \
			echo "Installing Kernel Modules"; \
			$(call make-kernel-target,INSTALL_MOD_PATH=$(MODULES_INTERMEDIATES) INSTALL_MOD_STRIP=1 modules_install); \
			$(if $(TARGET_KERNEL_EXT_MODULES),\
				echo "Building and Installing External Kernel Modules"; \
				rpath=$$(python3 -c 'import os,sys;print(os.path.relpath(*(sys.argv[1:])))' $(TARGET_KERNEL_EXT_MODULE_ROOT) $(KERNEL_SRC)); \
				$(foreach p, $(TARGET_KERNEL_EXT_MODULES),\
					$$pwd; \
					$(call $(if $(filter $(word 2,$(subst :, ,$(p))),kbuild),make-kbuild-module-target,make-external-module-target),$(word 1,$(subst :, ,$(p))),$$rpath,) || exit "$$?";  \
					$(call $(if $(filter $(word 2,$(subst :, ,$(p))),kbuild),make-kbuild-module-target,make-external-module-target),$(word 1,$(subst :, ,$(p))),$$rpath,INSTALL_MOD_PATH=$(MODULES_INTERMEDIATES) INSTALL_MOD_STRIP=1 KERNEL_UAPI_HEADERS_DIR=$(KERNEL_OUT) modules_install)) || exit "$$?"; \
			) \
			kernel_release=$$(cat $(KERNEL_RELEASE)) \
			kernel_modules_dir=$(MODULES_INTERMEDIATES)/lib/modules/$$kernel_release \
			all_modules=$$(find $$kernel_modules_dir -type f -name '*.ko') \
			$(foreach s, $(TARGET_MODULE_ALIASES),\
				$(eval p := $(subst :,$(space),$(s))) \
				; mv $$(echo $$all_modules | tr ' ' '\n' | grep /$(word 1,$(p))) $$kernel_modules_dir/$(word 2,$(p))); \
			all_modules=$$(find $$kernel_modules_dir -type f -name '*.ko'); \
			dup_modules=$$(echo $$all_modules | tr ' ' '\n' | xargs -n1 basename | sort | uniq -d); \
			$(if $$dup_modules,\
				err=$$(for m in $$dup_modules; do \
					echo "ERROR: Duplicate module $$m" 1>&2 && echo "dup"; \
				done); \
				[ -n "$$err" ] && exit 1; \
			) \
			filtered_modules=""; \
			$(if $(SYSTEM_KERNEL_MODULES),\
				gki_modules=$$(for m in $(SYSTEM_KERNEL_MODULES); do \
					p=$$(echo $$all_modules | tr ' ' '\n' | grep /$$m); \
					if [ -n "$$p" ]; then echo $$p; else echo "ERROR: $$m from SYSTEM_KERNEL_MODULES was not found" 1>&2 && exit 1; fi; \
				done); \
				[ $$? -ne 0 ] && exit 1; \
				($(call build-image-kernel-modules-lineage,$$gki_modules,$(SYSTEM_KERNEL_MODULES_OUT),$(SYSTEM_KERNEL_MODULE_MOUNTPOINT)/,$(SYSTEM_KERNEL_DEPMOD_STAGING_DIR),$(SYSTEM_KERNEL_MODULES_LOAD),$(GKI_SUFFIX),$(SYSTEM_KERNEL_MODULES_PARTITION_FILE_LIST),)) || exit "$$?"; \
				filtered_modules=$$(for n in $$all_modules; do \
					module_name=$$(basename $$n); \
					if [[ ! "$(SYSTEM_KERNEL_MODULES)" =~ "$$module_name" ]]; then echo $$n; fi; \
				done); \
				($(call build-image-kernel-modules-lineage,$$filtered_modules,$(KERNEL_MODULES_OUT),$(KERNEL_MODULE_MOUNTPOINT)/,$(KERNEL_DEPMOD_STAGING_DIR),$(BOARD_VENDOR_KERNEL_MODULES_LOAD),,$(KERNEL_MODULES_PARTITION_FILE_LIST),$(SYSTEM_KERNEL_DEPMOD_STAGING_DIR)/lib/modules/0.0/$(SYSTEM_KERNEL_MODULE_MOUNTPOINT))) || exit "$$?"; \
				if grep -q 'CONFIG_MODULE_SIG_FORMAT=y' $(KERNEL_CONFIG); then \
					(for m in $$(find $(SYSTEM_KERNEL_MODULES_OUT) -type f -name "*.ko"); do \
						$(KERNEL_OUT)/scripts/sign-file sha1 \
						$(KERNEL_OUT)/certs/signing_key.pem \
						$(KERNEL_OUT)/certs/signing_key.x509 "$$m"; \
					done) || exit "$$?"; \
				fi; \
				,\
				($(call build-image-kernel-modules-lineage,$$all_modules,$(KERNEL_MODULES_OUT),$(KERNEL_MODULE_MOUNTPOINT)/,$(KERNEL_DEPMOD_STAGING_DIR),$(BOARD_VENDOR_KERNEL_MODULES_LOAD),,$(KERNEL_MODULES_PARTITION_FILE_LIST),)) || exit "$$?"; \
			) \
			$(if $(BOOT_KERNEL_MODULES),\
				vendor_boot_modules=$$(for m in $(BOOT_KERNEL_MODULES); do \
					p=$$(echo $$all_modules | tr ' ' '\n' | grep /$$m); \
					if [ -n "$$p" ]; then echo $$p; else echo "ERROR: $$m from BOOT_KERNEL_MODULES was not found" 1>&2 && exit 1; fi; \
				done); \
				[ $$? -ne 0 ] && exit 1; \
				($(call build-image-kernel-modules-lineage,$$vendor_boot_modules,$(KERNEL_VENDOR_RAMDISK_MODULES_OUT),,$(KERNEL_VENDOR_RAMDISK_DEPMOD_STAGING_DIR),$(KERNEL_VENDOR_RAMDISK_KERNEL_MODULES_LOAD),,,)) || exit "$$?"; \
			) \
			$(if $(RECOVERY_KERNEL_MODULES),\
				recovery_modules=$$(for m in $(RECOVERY_KERNEL_MODULES); do \
					p=$$(echo $$all_modules | tr ' ' '\n' | grep /$$m); \
					if [ -n "$$p" ]; then echo $$p; else echo "ERROR: $$m from RECOVERY_KERNEL_MODULES was not found" 1>&2 && exit 1; fi; \
				done); \
				[ $$? -ne 0 ] && exit 1; \
				($(call build-image-kernel-modules-lineage,$$recovery_modules,$(KERNEL_RECOVERY_MODULES_OUT),,$(KERNEL_RECOVERY_DEPMOD_STAGING_DIR),$(BOARD_RECOVERY_KERNEL_MODULES_LOAD),,,)) || exit "$$?"; \
			) \
		fi

.PHONY: kerneltags
kerneltags: $(KERNEL_CONFIG)
	$(call make-kernel-target,tags)

.PHONY: kernelsavedefconfig alldefconfig kernelconfig

kernelsavedefconfig: $(KERNEL_OUT)
	$(call make-kernel-config,$(KERNEL_OUT),$(BASE_KERNEL_DEFCONFIG_SRC))
	$(call make-kernel-target,savedefconfig)
	cp $(KERNEL_OUT)/defconfig $(BASE_KERNEL_DEFCONFIG_SRC)

alldefconfig: $(KERNEL_OUT)
	env KCONFIG_NOTIMESTAMP=true \
		 $(call make-kernel-target,alldefconfig)

kernelconfig: $(KERNEL_OUT) $(ALL_KERNEL_DEFCONFIG_SRCS)
	@echo "Building Kernel Config"
	$(call make-kernel-config,$(KERNEL_OUT),$(ALL_KERNEL_DEFCONFIG_SRCS))

ifeq (true,$(filter true, $(TARGET_NEEDS_DTBOIMAGE) $(BOARD_KERNEL_SEPARATED_DTBO)))
ifneq ($(BOARD_CUSTOM_DTBOIMG_MK),)
include $(BOARD_CUSTOM_DTBOIMG_MK)
else
MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)
MKDTBOIMG := $(HOST_OUT_EXECUTABLES)/mkdtboimg$(HOST_EXECUTABLE_SUFFIX)

$(DTBO_OUT):
	mkdir -p $(DTBO_OUT)

ifeq ($(BOARD_USES_QCOM_MERGE_DTBS_SCRIPT),true)
$(BOARD_PREBUILT_DTBOIMAGE): $(INSTALLED_DTBIMAGE_TARGET)
else
$(BOARD_PREBUILT_DTBOIMAGE): $(DTBO_OUT)
endif
$(BOARD_PREBUILT_DTBOIMAGE): $(DTC) $(MKDTIMG) $(MKDTBOIMG)
$(BOARD_PREBUILT_DTBOIMAGE):
	@echo "Building dtbo.img"
ifeq ($(BOARD_USES_QCOM_MERGE_DTBS_SCRIPT),true)
	$(MKDTBOIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $(shell find $(DTBS_OUT) -type f -name "*.dtbo" | sort)
else
	$(hide) find $(DTBO_OUT)/arch/$(KERNEL_ARCH)/boot/dts -type f -name "*.dtbo" | xargs rm -f
	$(call make-dtbo-target,$(KERNEL_DEFCONFIG))
	$(call make-dtbo-target,$(TARGET_KERNEL_DTB))
ifeq ($(BOARD_KERNEL_SEPARATED_DTBO),true)
ifdef BOARD_DTBO_CFG
	$(MKDTBOIMG) cfg_create $@ $(BOARD_DTBO_CFG) -d $(DTBO_OUT)/arch/$(KERNEL_ARCH)/boot/dts
else
	$(MKDTBOIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $(shell find $(DTBO_OUT)/arch/$(KERNEL_ARCH)/boot/dts -type f -name "*.dtbo" | sort)
endif # BOARD_DTBO_CFG
else
	$(call make-dtbo-target,$(TARGET_KERNEL_DTBO))
endif # BOARD_KERNEL_SEPARATED_DTBO
	$(hide) touch -c $(DTBO_OUT)
endif # BOARD_USES_QCOM_MERGE_DTBS_SCRIPT
endif # BOARD_CUSTOM_DTBOIMG_MK
endif # TARGET_NEEDS_DTBOIMAGE/BOARD_KERNEL_SEPARATED_DTBO

ifeq ($(BOARD_INCLUDE_DTB_IN_BOOTIMG),true)
ifneq ($(BOARD_CUSTOM_DTBIMG_MK),)
include $(BOARD_CUSTOM_DTBIMG_MK)
else
ifeq ($(BOARD_PREBUILT_DTBIMAGE_DIR),)
$(DTB_OUT):
	mkdir -p $(DTB_OUT)
ifeq ($(BOARD_USES_QCOM_MERGE_DTBS_SCRIPT),true)
$(DTBS_BASE):
	mkdir -p $(DTBS_BASE)
$(DTBS_OUT):
	mkdir -p $(DTBS_OUT)
endif

ifdef BOARD_DTB_CFG
MKDTBOIMG := $(HOST_OUT_EXECUTABLES)/mkdtboimg$(HOST_EXECUTABLE_SUFFIX)
$(INSTALLED_DTBIMAGE_TARGET): $(MKDTBOIMG)
endif
ifeq ($(BOARD_USES_QCOM_MERGE_DTBS_SCRIPT),true)
$(INSTALLED_DTBIMAGE_TARGET): $(HOST_OUT_EXECUTABLES)/fdtget $(HOST_OUT_EXECUTABLES)/fdtput $(HOST_OUT_EXECUTABLES)/fdtoverlay $(HOST_OUT_EXECUTABLES)/fdtoverlaymerge $(HOST_OUT_EXECUTABLES)/ufdt_apply_overlay $(DTBS_BASE) $(DTBS_OUT)
endif
$(INSTALLED_DTBIMAGE_TARGET): $(DTC) $(DTB_OUT)
ifeq ($(TARGET_WANTS_EMPTY_DTB),true)
	@rm -f $@
	echo "empty" > $@
else
	@echo "Building dtb.img"
	$(hide) find $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts -type f -name "*.dtb" | xargs rm -f
	$(call make-kernel-config,$(DTB_OUT),$(ALL_KERNEL_DEFCONFIG_SRCS))
	$(call make-dtb-target,$(TARGET_KERNEL_DTB))
ifdef BOARD_DTB_CFG
	$(MKDTBOIMG) cfg_create $@ $(BOARD_DTB_CFG) -d $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts
else
ifeq ($(BOARD_USES_QCOM_MERGE_DTBS_SCRIPT),true)
	$(hide) find $(DTBS_BASE) -type f -name "*.dtb*" | xargs rm -f
	$(hide) find $(DTBS_OUT) -type f -name "*.dtb*" | xargs rm -f
	mv $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts/vendor/*/*.dtb $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts/vendor/*/*.dtbo $(DTBS_BASE)/
	PATH=$(abspath $(HOST_OUT_EXECUTABLES)):$${PATH} python3 $(BUILD_TOP)/vendor/lineage/build/tools/merge_dtbs.py --base $(DTBS_BASE) --techpack $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts/vendor/qcom --out $(DTBS_OUT)
	cat $(shell find $(DTBS_OUT) -type f -name "${TARGET_MERGE_DTBS_WILDCARD}.dtb" | sort) > $@
else
	@rm -f $@
	$(foreach dtb,$(TARGET_DTB_LIST_WILDCARD),\
		cat `find $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts/$(dir $(dtb)) -type f -name "$(notdir $(dtb)).dtb" | sort` >> $@;)
endif # BOARD_USES_QCOM_MERGE_DTBS_SCRIPT
endif # BOARD_DTB_CFG
	$(hide) touch -c $(DTB_OUT)
endif # !TARGET_WANTS_EMPTY_DTB

endif # !BOARD_PREBUILT_DTBIMAGE_DIR
endif # BOARD_CUSTOM_DTBIMG_MK
endif # BOARD_INCLUDE_DTB_IN_BOOTIMG

endif # FULL_KERNEL_BUILD

## Install it

ifeq ($(FULL_KERNEL_BUILD),true)

# Append DTBs to kernel image
# $(1): output directory path (The value passed to O=)
# $(2): output kernel image path
define append-dtbs-to-kernel-image
	$(hide) if grep -q '^CONFIG_OF=y' $(1)/.config; then \
			$(if $(BOARD_KERNEL_APPEND_DTBS),\
				echo "Appending DTBs to kernel image";\
				$(foreach dtb,$(BOARD_KERNEL_APPEND_DTBS),\
					cat `find $(1)/arch/$(KERNEL_ARCH)/boot/dts/$(dir $(dtb)) -maxdepth 1 -type f -name "$(notdir $(dtb))"` >> $(2);\
				)\
			)\
			true;\
		fi
endef

endif # FULL_KERNEL_BUILD

ifneq ($(TARGET_KERNEL_PLATFORM_TARGET),)
KERNEL_PATH := $(abspath $(BUILD_TOP)/../kernel-$(TARGET_KERNEL_VERSION))
$(TARGET_PREBUILT_INT_KERNEL): $(DEPMOD) $(KERNEL_MODULES_PARTITION_FILE_LIST) $(SYSTEM_KERNEL_MODULES_PARTITION_FILE_LIST)
	@echo "Building $(BOARD_KERNEL_IMAGE_NAME)"
	@mkdir -p $(KERNEL_OUT)
	$(hide) cd $(KERNEL_PATH) && python3 .repo/repo/repo manifest -o - -r > $(abspath $(KERNEL_OUT))/manifest.xml
	$(hide) cd $(KERNEL_PATH) && ./tools/bazel --output_user_root=$(abspath $(KERNEL_OUT)/bazel-out) --output_root=$(abspath $(KERNEL_OUT)/bazel-out) run --experimental_convenience_symlinks=ignore --cpu=$(KERNEL_ARCH) --repo_manifest $(abspath $(KERNEL_PATH)):$(abspath $(KERNEL_OUT)/manifest.xml) --config=stamp //$(KERNEL_SRC):$(TARGET_KERNEL_PLATFORM_TARGET)_dist -- --destdir=$(abspath $(KERNEL_OUT))
	$(if $(BOOT_KERNEL_MODULES),\
		$(call build-image-kernel-modules-lineage,$(addprefix $(KERNEL_OUT)/,$(BOOT_KERNEL_MODULES)),$(KERNEL_VENDOR_RAMDISK_MODULES_OUT),,$(KERNEL_VENDOR_RAMDISK_DEPMOD_STAGING_DIR),$(KERNEL_VENDOR_RAMDISK_KERNEL_MODULES_LOAD),,,)\
	)
	$(if $(RECOVERY_KERNEL_MODULES),\
		$(call build-image-kernel-modules-lineage,$(addprefix $(KERNEL_OUT)/,$(RECOVERY_KERNEL_MODULES)),$(KERNEL_RECOVERY_MODULES_OUT),,$(KERNEL_RECOVERY_DEPMOD_STAGING_DIR),$(BOARD_RECOVERY_KERNEL_MODULES_LOAD),,,)\
	)
	$(if $(filter $(TARGET_KERNEL_MIXED_MODE),true),\
		system_dlkm_modules=$$(awk -F'/' '{ print "$(KERNEL_OUT)/"$$NF }' $(KERNEL_OUT)/system_dlkm.modules.load); \
		($(call build-image-kernel-modules-lineage,$$system_dlkm_modules,$(SYSTEM_KERNEL_MODULES_OUT),$(SYSTEM_KERNEL_MODULE_MOUNTPOINT)/,$(SYSTEM_KERNEL_DEPMOD_STAGING_DIR),,,$(SYSTEM_KERNEL_MODULES_PARTITION_FILE_LIST),))\
	)
	vendor_modules=$$(comm -23 <(find $(KERNEL_OUT) -maxdepth 1 -type f -name '*.ko' | awk -F'/' '{ print $$NF }' | sort) <(awk -F'/' '{ print $$NF }' $(KERNEL_OUT)/system_dlkm.modules.load | sort) | sed 's|^|$(KERNEL_OUT)/|'); \
	($(call build-image-kernel-modules-lineage,$$vendor_modules,$(KERNEL_MODULES_OUT),$(KERNEL_MODULE_MOUNTPOINT)/,$(KERNEL_DEPMOD_STAGING_DIR),$(BOARD_VENDOR_KERNEL_MODULES_LOAD),,$(KERNEL_MODULES_PARTITION_FILE_LIST),$(SYSTEM_KERNEL_DEPMOD_STAGING_DIR)/lib/modules/0.0/$(SYSTEM_KERNEL_MODULE_MOUNTPOINT)))
endif

ifeq ($(NEEDS_KERNEL_COPY),true)
$(INSTALLED_KERNEL_TARGET): $(KERNEL_BIN)
	$(transform-prebuilt-to-target)
	$(if $(filter true,$(FULL_KERNEL_BUILD)),\
		$(call append-dtbs-to-kernel-image,$(KERNEL_OUT),$@))
endif

.PHONY: kernel
kernel: $(INSTALLED_KERNEL_TARGET)

.PHONY: dtboimage
dtboimage: $(INSTALLED_DTBOIMAGE_TARGET)

.PHONY: dtbimage
dtbimage: $(INSTALLED_DTBIMAGE_TARGET)

endif # TARGET_NO_KERNEL_OVERRIDE
endif # TARGET_NO_KERNEL
