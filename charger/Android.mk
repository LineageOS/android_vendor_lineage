LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := healthd_board_cm.cpp
LOCAL_MODULE := libhealthd.cm
LOCAL_CFLAGS := -Werror
LOCAL_C_INCLUDES := \
    system/core/healthd \
    bootable/recovery
ifneq ($(BACKLIGHT_PATH),)
    LOCAL_CFLAGS += -DHEALTHD_BACKLIGHT_PATH=\"$(BACKLIGHT_PATH)\"
endif
ifneq ($(SECONDARY_BACKLIGHT_PATH),)
    LOCAL_CFLAGS += -DHEALTHD_SECONDARY_BACKLIGHT_PATH=\"$(SECONDARY_BACKLIGHT_PATH)\"
endif
ifneq ($(HEALTHD_BACKLIGHT_LEVEL),)
    LOCAL_CFLAGS += -DHEALTHD_BACKLIGHT_LEVEL=$(HEALTHD_BACKLIGHT_LEVEL)
endif
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := font_log.png
LOCAL_SRC_FILES := fonts/$(PRODUCT_AAPT_PREF_CONFIG)/font_log.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)/res/images
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)

define _add-charger-image
include $$(CLEAR_VARS)
LOCAL_MODULE := vendor_cm_charger_$(notdir $(1))
LOCAL_MODULE_STEM := $(notdir $(1))
_img_modules += $$(LOCAL_MODULE)
LOCAL_SRC_FILES := $1
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $$(TARGET_ROOT_OUT)/res/images/charger
include $$(BUILD_PREBUILT)
endef

_img_modules :=
_images :=
$(foreach _img, $(call find-subdir-subdir-files, "images/$(PRODUCT_AAPT_PREF_CONFIG)", "*.png"), \
  $(eval $(call _add-charger-image,$(_img))))

include $(CLEAR_VARS)
LOCAL_MODULE := cm_charger_res_images
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(_img_modules)
LOCAL_OVERRIDES_PACKAGES := charger_res_images
include $(BUILD_PHONY_PACKAGE)

_add-charger-image :=
_img_modules :=
