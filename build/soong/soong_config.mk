add_json_str_omitempty = $(if $(strip $(2)),$(call add_json_str, $(1), $(2)))
add_json_val_default = $(call add_json_val, $(1), $(if $(strip $(2)), $(2), $(3)))

_json_contents := $(_json_contents)    "Lineage":{$(newline)

# See build/core/soong_config.mk for the add_json_* functions you can use here.
$(call add_json_str_omitempty, Additional_gralloc_10_usage_bits, $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS))
$(call add_json_bool, Apply_msm8974_1440p_egl_workaround, $(filter true,$(TARGET_MSM8974_1440P_EGL_WORKAROUND)))
$(call add_json_val_default, Bootloader_message_offset, $(BOOTLOADER_MESSAGE_OFFSET), 0)
$(call add_json_bool, Has_legacy_camera_hal1, $(filter true,$(TARGET_HAS_LEGACY_CAMERA_HAL1)))
$(call add_json_bool, Should_skip_waiting_for_qsee, $(filter true,$(TARGET_KEYMASTER_SKIP_WAITING_FOR_QSEE)))
$(call add_json_str, Specific_camera_parameter_library, $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY))
$(call add_json_bool, Supports_hw_fde, $(filter true,$(TARGET_HW_DISK_ENCRYPTION)))
$(call add_json_bool, Supports_hw_fde_perf, $(filter true,$(TARGET_HW_DISK_ENCRYPTION_PERF)))
$(call add_json_bool, Supports_legacy_hw_fde, $(filter true,$(TARGET_LEGACY_HW_DISK_ENCRYPTION)))
$(call add_json_str_omitempty, Target_process_sdk_version_override, $(TARGET_PROCESS_SDK_VERSION_OVERRIDE))
$(call add_json_str_omitempty, Target_shim_libs, $(TARGET_LD_SHIM_LIBS))
$(call add_json_bool, Uses_generic_camera_parameter_library, $(if $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY),,true))
$(call add_json_bool, Uses_metadata_as_fde_key, $(filter true,$(TARGET_USES_METADATA_AS_FDE_KEY)))
$(call add_json_bool, Uses_nvidia_enhancements, $(filter TRUE,$(NV_ANDROID_FRAMEWORK_ENHANCEMENTS)))
$(call add_json_bool, Uses_qcom_bsp_legacy, $(filter true,$(TARGET_USES_QCOM_BSP_LEGACY)))
$(call add_json_bool, Uses_qti_camera_device, $(filter true,$(TARGET_USES_QTI_CAMERA_DEVICE)))
$(call add_json_bool, Uses_qcom_um_family, $(filter true,$(TARGET_USES_QCOM_UM_FAMILY)))
$(call add_json_bool, Uses_qcom_um_3_18_family, $(filter true,$(TARGET_USES_QCOM_UM_3_18_FAMILY)))
$(call add_json_bool, Uses_qcom_um_4_4_family, $(filter true,$(TARGET_USES_QCOM_UM_4_4_FAMILY)))
$(call add_json_bool, Uses_qcom_um_4_9_family, $(filter true,$(TARGET_USES_QCOM_UM_4_9_FAMILY)))
$(call add_json_bool, Uses_qcom_um_4_14_family, $(filter true,$(TARGET_USES_QCOM_UM_4_14_FAMILY)))

# This causes the build system to strip out the last comma in our nested struct, to keep the JSON valid.
_json_contents := $(_json_contents)__SV_END

_json_contents := $(_json_contents)    },$(newline)
