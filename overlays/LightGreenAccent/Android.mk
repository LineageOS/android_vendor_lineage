LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_RRO_THEME := LightGreenAccentOverlay
LOCAL_CERTIFICATE := platform
LOCAL_SRC_FILES := $(call all-subdir-java-files)
LOCAL_RESOURCE_DIR := $(LOCAL_PATH)/res
LOCAL_PACKAGE_NAME := LightGreenAccentOverlay

include $(BUILD_RRO_PACKAGE)
