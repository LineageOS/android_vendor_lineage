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

# Bootanimation
TARGET_BOOTANIMATION_HALF_RES ?= false
$(call soong_config_set,lineage_bootanimation,height,$(TARGET_SCREEN_HEIGHT))
$(call soong_config_set,lineage_bootanimation,width,$(TARGET_SCREEN_WIDTH))
$(call soong_config_set,lineage_bootanimation,half_res,$(TARGET_BOOTANIMATION_HALF_RES))

ifneq ($(TARGET_BOOTANIMATION),)
$(call soong_config_set,lineage_bootanimation,prebuilt_file,$(TARGET_BOOTANIMATION))
endif

# Camera
ifneq ($(TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED),)
    $(error TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED is deprecated, please migrate to soong_config_set,camera,override_format_from_reserved)
endif

# Charger
lineage_charger_density := mdpi
ifneq (,$(TARGET_SCREEN_DENSITY))
lineage_charger_density := $(strip \
  $(or $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 560))),1),xxxhdpi),\
       $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 400))),1),xxhdpi),\
       $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 280))),1),xhdpi),\
       $(if $(filter $(shell echo $$(($(TARGET_SCREEN_DENSITY) >= 200))),1),hdpi,mdpi)))
else ifneq (,$(filter mdpi hdpi xhdpi xxhdpi xxxhdpi,$(PRODUCT_AAPT_PREF_CONFIG)))
# If PRODUCT_AAPT_PREF_CONFIG includes a dpi bucket, then use that value.
lineage_charger_density := $(PRODUCT_AAPT_PREF_CONFIG)
endif
$(call soong_config_set,lineage_charger,density,$(lineage_charger_density))

# Libui
ifneq ($(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS),)
    $(call soong_config_set,libui,additional_gralloc_10_usage_bits,$(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS))
endif

# Lineage Health HAL
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH is deprecated, please migrate to soong_config_set,lineage_health,charging_control_charging_path)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_DEADLINE_PATH),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_DEADLINE_PATH is deprecated, please migrate to soong_config_set,lineage_health,charging_control_deadline_path)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED is deprecated, please migrate to soong_config_set,lineage_health,charging_control_charging_enabled)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED is deprecated, please migrate to soong_config_set,lineage_health,charging_control_charging_disabled)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_bypass)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_DEADLINE is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_deadline)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_LIMIT is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_limit)
endif
ifneq ($(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE),)
    $(error TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_TOGGLE is deprecated, please migrate to soong_config_set,lineage_health,charging_control_supports_toggle)
endif

# Surfaceflinger
ifneq ($(TARGET_SURFACEFLINGER_UDFPS_LIB),)
    $(error TARGET_SURFACEFLINGER_UDFPS_LIB is deprecated, please migrate to soong_config_set,surfaceflinger,udfps_lib)
endif

# Vendor init
ifneq ($(TARGET_INIT_VENDOR_LIB),)
    $(error TARGET_INIT_VENDOR_LIB is deprecated, please migrate to soong_config_set,libinit,vendor_init_lib)
endif
