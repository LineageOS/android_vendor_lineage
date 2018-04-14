# Lineage prebuilt hooks
#
# These are called from the main build system (build/make/core):
#  base_rules.mk: base-rules-hook
#  executable_internal.mk: target-executable-hook
#  host_executable_internal.mk: host-executable-hook
#  host_shared_library_internal.mk: host-shared-library-hook
#  shared_library_internal.mk: target-shared-library-hook

ifeq (,$(strip $(CACHE_DIR_COMMON_BASE)))
CACHE_ROOT := $(PWD)/.cache
else
CACHE_ROOT := $(PREBUILT_DIR_COMMON_BASE)/$(notdir $(PWD))
endif

PREBUILT_CACHE_DIR := $(CACHE_ROOT)/prebuilt

TARGET_CACHE_ROOT := $(PREBUILT_CACHE_DIR)/target
HOST_CACHE_ROOT := $(PREBUILT_CACHE_DIR)/host

TARGET_PRODUCT_CACHE_ROOT := $(TARGET_CACHE_ROOT)/product

PRODUCT_CACHE := $(TARGET_PRODUCT_CACHE_ROOT)/$(TARGET_DEVICE)
HOST_CACHE := $(HOST_CACHE_ROOT)/$(HOST_OS)-$(HOST_PREBUILT_ARCH)

TARGET_CACHE_INTERMEDIATES := $(PRODUCT_CACHE)/obj
$(TARGET_2ND_ARCH_VAR_PREFIX)TARGET_CACHE_INTERMEDIATES := $(PRODUCT_CACHE)/obj_$(TARGET_2ND_ARCH)

HOST_CACHE_INTERMEDIATES := $(HOST_CACHE)/obj
$(HOST_2ND_ARCH_VAR_PREFIX)HOST_CACHE_INTERMEDIATES := $(HOST_CACHE)/obj32

KERNEL_CACHE := $(TARGET_CACHE_INTERMEDIATES)/KERNEL_OBJ

# $(1): target class, like "APPS"
# $(2): target name, like "NotePad"
# $(3): { HOST, HOST_CROSS, AUX, <empty (TARGET)>, <other non-empty (HOST)> }
# $(4): if non-empty, force the intermediates to be COMMON
# $(5): if non-empty, force the intermediates to be for the 2nd arch
# $(6): if non-empty, force the intermediates to be for the host cross os

define cache-dir-for
$(strip \
    $(eval _idfClass := $(strip $(1))) \
    $(eval _idfName := $(strip $(2))) \
    $(eval _idfPrefix := $(call find-idf-prefix,$(3),$(6))) \
    $(eval _idf2ndArchPrefix := $(if $(strip $(5)),$(TARGET_2ND_ARCH_VAR_PREFIX))) \
    $(if $(filter $(_idfPrefix)-$(_idfClass),$(COMMON_MODULE_CLASSES))$(4), \
        $(eval _idfIntBase := $($(_idfPrefix)_OUT_COMMON_INTERMEDIATES)) \
      ,$(if $(filter $(_idfClass),$(PER_ARCH_MODULE_CLASSES)),\
          $(eval _idfIntBase := $($(_idf2ndArchPrefix)$(_idfPrefix)_CACHE_INTERMEDIATES)) \
       ,$(eval _idfIntBase := $($(_idfPrefix)_CACHE_INTERMEDIATES)) \
       ) \
     ) \
    $(_idfIntBase)/$(_idfClass)/$(_idfName)_intermediates \
)
endef

define local-cache-dir
$(strip \
    $(call cache-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),$(call def-host-aux-target),$(1),$(2),$(3)) \
)
endef

define target-save-prebuilt-library
vendor/lineage/build/tools/save_prebuilt_library \
	$(PRODUCT_CACHE) $(PRODUCT_OUT) \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_INTERMEDIATES_DIR) \
	$(PRIVATE_MODULE_PATH) $(PRIVATE_MODULE_NAME) $(PRIVATE_SRC_FILES)
endef

define target-load-export-includes
vendor/lineage/build/tools/load_export_includes \
	$(PRODUCT_CACHE) $(PRODUCT_OUT) \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_INTERMEDIATES_DIR)
endef

define host-save-prebuilt-library
vendor/lineage/build/tools/save_prebuilt_library \
	$(HOST_CACHE) $(HOST_OUT) \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_INTERMEDIATES_DIR) \
	$(PRIVATE_MODULE_PATH) $(PRIVATE_MODULE_NAME) $(PRIVATE_SRC_FILES)
endef

define host-load-export-includes
vendor/lineage/build/tools/load_export_includes \
	$(HOST_CACHE) $(HOST_OUT) \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_INTERMEDIATES_DIR)
endef

define target-shared-library-hook
$(strip \
  $(eval include $$(BUILD_SYSTEM)/configure_module_stem.mk) \
  $(eval intermediates_dir := $$(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval cache_dir := $$(call local-cache-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval module_relative_name := LINKED/$(notdir $$(my_installed_module_stem))) \
  $(eval LOCAL_PREBUILT_MODULE_FILE := \
    $$(shell vendor/lineage/build/tools/check_prebuilt_library \
        $(PRODUCT_OUT) $(PRODUCT_CACHE) $(TARGET_KERNEL_SOURCE) $(TARGET_KERNEL_ARCH) \
        $(cache_dir) $(module_relative_name) $(LOCAL_SRC_FILES))) \
)
endef

define target-static-library-hook
$(strip \
  $(eval include $$(BUILD_SYSTEM)/configure_module_stem.mk) \
  $(eval intermediates_dir := $$(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval cache_dir := $$(call local-cache-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval module_relative_name := $$(my_built_module_stem)) \
  $(eval LOCAL_PREBUILT_MODULE_FILE := \
    $$(shell vendor/lineage/build/tools/check_prebuilt_library \
        $(PRODUCT_OUT) $(PRODUCT_CACHE) $(TARGET_KERNEL_SOURCE) $(TARGET_KERNEL_ARCH) \
        $(cache_dir) $(module_relative_name) $(LOCAL_SRC_FILES))) \
)
endef

define host-shared-library-hook
$(strip \
  $(eval include $$(BUILD_SYSTEM)/configure_module_stem.mk) \
  $(eval intermediates_dir := $$(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval cache_dir := $$(call local-cache-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval module_relative_name := $$(my_built_module_stem)) \
  $(eval LOCAL_PREBUILT_MODULE_FILE := \
    $$(shell vendor/lineage/build/tools/check_prebuilt_library \
        $(HOST_OUT) $(HOST_CACHE) $(TARGET_KERNEL_SOURCE) $(TARGET_KERNEL_ARCH) \
        $(cache_dir) $(module_relative_name) $(LOCAL_SRC_FILES))) \
)
endef

define host-static-library-hook
$(strip \
  $(eval include $$(BUILD_SYSTEM)/configure_module_stem.mk) \
  $(eval intermediates_dir := $$(call local-intermediates-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval cache_dir := $$(call local-cache-dir,,$(LOCAL_2ND_ARCH_VAR_PREFIX))) \
  $(eval module_relative_name := $$(my_built_module_stem)) \
  $(eval LOCAL_PREBUILT_MODULE_FILE := \
    $$(shell vendor/lineage/build/tools/check_prebuilt_library \
        $(HOST_OUT) $(HOST_CACHE) $(TARGET_KERNEL_SOURCE) $(TARGET_KERNEL_ARCH) \
        $(cache_dir) $(module_relative_name) $(LOCAL_SRC_FILES))) \
)
endef

define save-prebuilt-kernel-binaries
vendor/lineage/build/tools/save_prebuilt_kernel_binaries \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_OBJECT_DIR) $(PRIVATE_SOURCE_DIR) \
	$(PRIVATE_KERNEL_IMG) $(PRIVATE_MODULE_DIR)
endef

define save-prebuilt-kernel-headers
vendor/lineage/build/tools/save_prebuilt_kernel_headers \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_OBJECT_DIR)
endef

define load-prebuilt-kernel-binaries
vendor/lineage/build/tools/load_prebuilt_kernel_binaries \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_OBJECT_DIR) \
	$(PRIVATE_KERNEL_IMG) $(PRIVATE_MODULE_DIR)
endef

define load-prebuilt-kernel-headers
vendor/lineage/build/tools/load_prebuilt_kernel_headers \
	$(PRIVATE_CACHE_DIR) $(PRIVATE_OBJECT_DIR)
endef

define target-kernel-hook
$(strip \
  $(eval HAVE_CACHED_KERNEL := $$(shell vendor/lineage/build/tools/check_cached_kernel $(KERNEL_CACHE) $(TARGET_KERNEL_SOURCE))) \
)
endef
