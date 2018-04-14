# Lineage specific build config

# The core build system uses ANDROID_BUILD_FROM_SOURCE to determine
# whether to use prebuilts and defaults to enabled.
#
# Lineage uses USE_PREBUILTCACHE to determine whether to use prebuilts
# and defaults to false.
#
# Make the conversion here.
ifeq ($(filter-out false,$(USE_PREBUILTCACHE)),)
ANDROID_BUILD_FROM_SOURCE := true
endif

ifneq (true,$(ANDROID_BUILD_FROM_SOURCE))
include vendor/lineage/build/core/prebuilt_hooks.mk
endif
