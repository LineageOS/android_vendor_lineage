ifneq ($(TARGET_NO_KERNEL),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTBO)),true)

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_DTBOIMAGE_TARGET := $(PRODUCT_OUT)/dtbo.img

# Most specific paths must come first in possible_dtbo_dirs
possible_dtbo_dirs = $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts

define build-dtboimage-target
    $(call pretty,"Target dtbo image: $(INSTALLED_DTBOIMAGE_TARGET)")
    $(hide) for dir in $(possible_dtbo_dirs); do \
                if [ -d "$$dir" ]; then \
                    dtbo_dir="$$dir"; \
                    break; \
                fi; \
            done; \
            dtbo_objs=$$(find "$$dtbo_dir" -name '*.dtbo')
    $(hide) $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) "$$dtbo_objs"
    $(hide) chmod a+r $@
endef

$(INSTALLED_DTBOIMAGE_TARGET): $(AVBTOOL) $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)

endif # BOARD_KERNEL_SEPARATED_DTBO
endif # TARGET_NO_KERNEL
