add_json_str_omitempty = $(if $(strip $(2)),$(call add_json_str, $(1), $(2)))
add_json_val_default = $(call add_json_val, $(1), $(if $(strip $(2)), $(2), $(3)))

_json_contents := $(_json_contents)    "Lineage":{$(newline)

# See build/core/soong_config.mk for the add_json_* functions you can use here.
$(call add_json_str_omitempty, Additional_gralloc_10_usage_bits, $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS))
$(call add_json_bool, Apply_msm8974_1440p_egl_workaround, $(filter true,$(TARGET_MSM8974_1440P_EGL_WORKAROUND)))
$(call add_json_val_default, Bootloader_message_offset, $(BOOTLOADER_MESSAGE_OFFSET), 0)
$(call add_json_bool, Has_legacy_camera_hal1, $(filter true,$(TARGET_HAS_LEGACY_CAMERA_HAL1)))
$(call add_json_str_omitempty, Qcom_um_soong_namespace, $(if $(filter $(UM_PLATFORMS),$(TARGET_BOARD_PLATFORM)),$(QCOM_SOONG_NAMESPACE),))
$(call add_json_bool, Recovery_skip_ev_rel_input, $(filter true,$(TARGET_RECOVERY_SKIP_EV_REL_INPUT)))
$(call add_json_bool, Should_wait_for_qsee, $(filter true,$(TARGET_KEYMASTER_WAIT_FOR_QSEE)))
$(call add_json_str, Specific_camera_parameter_library, $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY))
$(call add_json_bool, Supports_extended_compress_format, $(filter true,$(AUDIO_FEATURE_ENABLED_EXTENDED_COMPRESS_FORMAT)))
$(call add_json_bool, Supports_hw_fde, $(filter true,$(TARGET_HW_DISK_ENCRYPTION)))
$(call add_json_bool, Supports_hw_fde_perf, $(filter true,$(TARGET_HW_DISK_ENCRYPTION_PERF)))
$(call add_json_bool, Target_ignores_ftp_pptp_conntrack_failure, $(filter true,$(TARGET_IGNORES_FTP_PPTP_CONNTRACK_FAILURE)))
$(call add_json_str_omitempty, Target_init_vendor_lib, $(TARGET_INIT_VENDOR_LIB))
$(call add_json_bool, Target_needs_netd_direct_connect_rule, $(filter true,$(TARGET_NEEDS_NETD_DIRECT_CONNECT_RULE)))
$(call add_json_str_omitempty, Target_process_sdk_version_override, $(TARGET_PROCESS_SDK_VERSION_OVERRIDE))
$(call add_json_str_omitempty, Target_shim_libs, $(subst $(space),:,$(TARGET_LD_SHIM_LIBS)))
$(call add_json_str_omitempty, Target_specific_header_path, $(TARGET_SPECIFIC_HEADER_PATH))
$(call add_json_str_omitempty, Target_surfaceflinger_fod_lib, $(TARGET_SURFACEFLINGER_FOD_LIB))
$(call add_json_bool, Uses_generic_camera_parameter_library, $(if $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY),,true))
$(call add_json_bool, Uses_nvidia_enhancements, $(filter TRUE,$(NV_ANDROID_FRAMEWORK_ENHANCEMENTS)))
$(call add_json_bool, Uses_qcom_bsp_legacy, $(filter true,$(TARGET_USES_QCOM_BSP_LEGACY)))
$(call add_json_bool, Uses_qti_camera_device, $(filter true,$(TARGET_USES_QTI_CAMERA_DEVICE)))

# This causes the build system to strip out the last comma in our nested struct, to keep the JSON valid.
_json_contents := $(_json_contents)__SV_END

_json_contents := $(_json_contents)    },$(newline)
