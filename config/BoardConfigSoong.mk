PATH_OVERRIDE_SOONG := $(shell echo $(TOOLS_PATH_OVERRIDE))

# Add variables that we wish to make available to soong here.
EXPORT_TO_SOONG := \
    KERNEL_ARCH \
    KERNEL_BUILD_OUT_PREFIX \
    KERNEL_CROSS_COMPILE \
    KERNEL_MAKE_CMD \
    KERNEL_MAKE_FLAGS \
    KERNEL_PATH \
    PATH_OVERRIDE_SOONG \
    TARGET_KERNEL_CONFIG \
    TARGET_KERNEL_SOURCE \
    TARGET_KERNEL_PLATFORM_TARGET \
    TARGET_PREBUILT_KERNEL_HEADERS

# Setup SOONG_CONFIG_* vars to export the vars listed above.
# Documentation here:
# https://github.com/LineageOS/android_build_soong/commit/8328367c44085b948c003116c0ed74a047237a69

$(call add_soong_config_namespace,lineageVarsPlugin)
$(foreach v,$(EXPORT_TO_SOONG),$(eval $(call add_soong_config_var,lineageVarsPlugin,$(v))))

# Camera
ifneq ($(TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED),)
    $(warning TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED is deprecated, please migrate to soong_config_set,camera,override_format_from_reserved)
    $(call soong_config_set,camera,override_format_from_reserved,$(TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED))
endif

# Libui
ifneq ($(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS),)
    $(call soong_config_set,libui,additional_gralloc_10_usage_bits,$(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS))
endif

# Lineage Health HAL
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH is deprecated, please migrate to soong_config_set,lineage_health,charging_control_charging_path)
    $(call soong_config_set,lineage_health,charging_control_charging_path,$(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_DEADLINE_PATH),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_DEADLINE_PATH is deprecated, please migrate to soong_config_set,lineage_health,charging_control_deadline_path)
    $(call soong_config_set,lineage_health,charging_control_deadline_path,$(TARGET_HEALTH_CHARGING_CONTROL_DEADLINE_PATH))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED is deprecated, please migrate to soong_config_set,lineage_health,charging_control_charging_enabled)
    $(call soong_config_set,lineage_health,charging_control_charging_enabled,$(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED is deprecated, please migrate to soong_config_set,lineage_health,charging_control_charging_disabled)
    $(call soong_config_set,lineage_health,charging_control_charging_disabled,$(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_bypass)
    $(call soong_config_set,lineage_health,charging_control_supports_bypass,$(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_deadline)
    $(call soong_config_set,lineage_health,charging_control_supports_deadline,$(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_limit)
    $(call soong_config_set,lineage_health,charging_control_supports_limit,$(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT))
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE),)
    $(warning TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_toggle)
    $(call soong_config_set,lineage_health,charging_control_supports_toggle,$(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE))
endif

# Surfaceflinger
ifneq ($(TARGET_SURFACEFLINGER_UDFPS_LIB),)
    $(warning TARGET_SURFACEFLINGER_UDFPS_LIB is deprecated, please migrate to soong_config_set,surfaceflinger,udfps_lib)
    $(call soong_config_set,surfaceflinger,udfps_lib,$(TARGET_SURFACEFLINGER_UDFPS_LIB))
endif

# Vendor init
ifneq ($(TARGET_INIT_VENDOR_LIB),)
    $(warning TARGET_INIT_VENDOR_LIB is deprecated, please migrate to soong_config_set,libinit,vendor_init_lib)
    $(call soong_config_set,libinit,vendor_init_lib,$(TARGET_INIT_VENDOR_LIB))
endif
