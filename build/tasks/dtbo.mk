ifneq ($(TARGET_NO_KERNEL),true)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTBO)),true)

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_DTBOIMAGE_TARGET := $(PRODUCT_OUT)/dtbo.img

# Most specific paths must come first in possible_dtbo_dirs
possible_dtbo_dirs = $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts
$(shell mkdir -p $(possible_dtbo_dirs))
dtbo_dir = $(firstword $(wildcard $(possible_dtbo_dirs)))
dtbo_objs = $(shell find $(dtbo_dir) -name \*.dtbo)

define build-dtboimage-target
    $(call pretty,"Target dtbo image: $(INSTALLED_DTBOIMAGE_TARGET)")
    $(hide) $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $(dtbo_objs)
    $(hide) chmod a+r $@
endef

$(INSTALLED_DTBOIMAGE_TARGET): $(AVBTOOL) $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)

.PHONY: dtbo
dtbo: $(INSTALLED_DTBOIMAGE_TARGET)

endif # BOARD_KERNEL_SEPARATED_DTBO
endif # TARGET_NO_KERNEL
