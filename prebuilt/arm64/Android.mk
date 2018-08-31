ifneq (,$(filter $(TARGET_ARCH), arm64))

LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

endif
