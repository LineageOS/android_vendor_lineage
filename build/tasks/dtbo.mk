ifneq ($(TARGET_NO_KERNEL),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTBO)),true)

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_DTBOIMAGE_TARGET := $(PRODUCT_OUT)/dtbo.img

# Most specific paths must come first in possible_dtbo_dirs
possible_dtbo_dirs = $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts

define build-dtboimage-target
    $(call pretty,"Target dtbo image: $(INSTALLED_DTBOIMAGE_TARGET)")
    $(hide) for dir in $(possible_dtbo_dirs); do \
                if [ -d "$$dir" ]; then \
                    dtbo_dir="$$dir"; \
                    break; \
                fi; \
            done; \
            $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $$(find "$$dtbo_dir" -name '*.dtbo')
    $(hide) chmod a+r $@
endef

ifeq ($(BOARD_AVB_ENABLE),true)
$(INSTALLED_DTBOIMAGE_TARGET): $(AVBTOOL) $(BOARD_AVB_DTBO_KEY_PATH) $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)
	$(AVBTOOL) add_hash_footer \
		--image $@ \
		--partition_size $(BOARD_DTBOIMG_PARTITION_SIZE) \
		--partition_name dtbo $(INTERNAL_AVB_DTBO_SIGNING_ARGS) \
		$(BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS)
else
$(INSTALLED_DTBOIMAGE_TARGET): $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)
endif

endif # BOARD_KERNEL_SEPARATED_DTBO
endif # TARGET_NO_KERNEL
