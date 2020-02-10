ifneq ($(TARGET_NO_KERNEL),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTBO)),true)

ifneq ($(BOARD_CUSTOM_DTBOIMG_MK),)
include $(BOARD_CUSTOM_DTBOIMG_MK)
else

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

# Most specific paths must come first in possible_dtbo_dirs
possible_dtbo_dirs = $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts

define build-dtboimage-target
    $(call pretty,"Target dtbo image: $(BOARD_PREBUILT_DTBOIMAGE)")
    $(hide) for dir in $(possible_dtbo_dirs); do \
                if [ -d "$$dir" ]; then \
                    dtbo_dir="$$dir"; \
                    break; \
                fi; \
            done; \
            $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $$(find "$$dtbo_dir" -name '*.dtbo')
    $(hide) chmod a+r $@
endef

$(BOARD_PREBUILT_DTBOIMAGE): $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)

endif # BOARD_CUSTOM_DTBOIMG_MK
endif # BOARD_KERNEL_SEPARATED_DTBO
endif # TARGET_NO_KERNEL
