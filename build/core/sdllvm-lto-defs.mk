ifeq ($(LOCAL_MODULE_CLASS), STATIC_LIBRARIES)
# For STATIC_LIBRARIES we need to use SD LLVM's archiver and archiver flags.

AR := $(SDCLANG_PATH)/llvm-ar

ifeq ($(LOCAL_SDCLANG_2),true)
AR := $(SDCLANG_PATH_2)/llvm-ar
endif

ARFLAGS := crsD

# For 32 bit
$(LOCAL_BUILT_MODULE) : $(combo_2nd_arch_prefix)TARGET_AR := $(AR)
$(LOCAL_BUILT_MODULE) : $(combo_var_prefix)GLOBAL_ARFLAGS := $(ARFLAGS)

# For 64 bit
intermediates := $(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))
LOCAL_BUILT_MODULE_64 := $(intermediates)/$(my_installed_module_stem)

$(LOCAL_BUILT_MODULE_64) : TARGET_AR := $(AR)
$(LOCAL_BUILT_MODULE_64) : TARGET_GLOBAL_ARFLAGS := $(ARFLAGS)

else
# For SHARED_LIBRARIES and EXECUTABLES we need to filter out flags not
# needed/understood by SD LLVM's Linker.

FLAGS_TO_BE_FILTERED := -Wl,--icf=safe -Wl,--no-undefined-version -Wl,--fix-cortex-a53-843419 -fuse-ld=gold
linked_module_32 := $(intermediates)/LINKED/$(my_installed_module_stem)
intermediates    := $(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))
linked_module_64 := $(intermediates)/LINKED/$(my_installed_module_stem)

$(linked_module_32) : PRIVATE_TARGET_GLOBAL_LDFLAGS := $(filter-out $(FLAGS_TO_BE_FILTERED),$(PRIVATE_TARGET_GLOBAL_LDFLAGS))
$(linked_module_64) : PRIVATE_TARGET_GLOBAL_LDFLAGS := $(filter-out $(FLAGS_TO_BE_FILTERED),$(PRIVATE_TARGET_GLOBAL_LDFLAGS))
endif
