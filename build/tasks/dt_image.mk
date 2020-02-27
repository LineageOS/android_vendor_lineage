ifneq ($(TARGET_NO_KERNEL),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DT)),true)

ifneq ($(BOARD_CUSTOM_DTIMG_MK),)
include $(BOARD_CUSTOM_DTIMG_MK)
else

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

# Most specific paths must come first in possible_dt_dirs
possible_dt_dirs = $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts

define build-dtimage-target
    $(call pretty,"Target dt image: $(BOARD_PREBUILT_DTIMAGE)")
    $(hide) for dir in $(possible_dt_dirs); do \
                if [ -d "$$dir" ]; then \
                    dt_dir="$$dir"; \
                    break; \
                fi; \
            done; \
            $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $$(find "$$dt_dir" -type f -name '*.dtb' | sort)
    $(hide) chmod a+r $@
endef

$(BOARD_PREBUILT_DTIMAGE): $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtimage-target)

endif # BOARD_CUSTOM_DTIMG_MK
endif # BOARD_KERNEL_SEPARATED_DT
endif # TARGET_NO_KERNEL
