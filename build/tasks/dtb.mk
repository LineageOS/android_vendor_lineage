ifneq ($(TARGET_NO_KERNEL),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTB)),true)

ifneq ($(BOARD_CUSTOM_DTBIMG_MK),)
include $(BOARD_CUSTOM_DTBIMG_MK)
else

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

# Most specific paths must come first in possible_dtb_dirs
possible_dtb_dirs = $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts

define build-dtbimage-target
    $(call pretty,"Target dtb image: $(BOARD_PREBUILT_DTBIMAGE)")
    $(hide) for dir in $(possible_dtb_dirs); do \
                if [ -d "$$dir" ]; then \
                    dtb_dir="$$dir"; \
                    break; \
                fi; \
            done; \
            $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $$(find "$$dtb_dir" -type f -name '*.dtb' | sort)
    $(hide) chmod a+r $@
endef

$(BOARD_PREBUILT_DTBIMAGE): $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtbimage-target)

endif # BOARD_CUSTOM_DTBIMG_MK
endif # BOARD_KERNEL_SEPARATED_DTB
endif # TARGET_NO_KERNEL
