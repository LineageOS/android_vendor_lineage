LOCAL_PATH := $(call my-dir)

# a wrapper for curl which provides wget syntax, for compatibility
include $(CLEAR_VARS)
LOCAL_MODULE := wget
LOCAL_SRC_FILES := bin/wget
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := fonts_customization.xml
LOCAL_SRC_FILES := etc/fonts_customization.xml
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_PRODUCT_MODULE := true
include $(BUILD_PREBUILT)
