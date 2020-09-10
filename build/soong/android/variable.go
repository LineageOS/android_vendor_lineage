package android
type Product_variables struct {
	Additional_gralloc_10_usage_bits struct {
		Cppflags []string
	}
	Apply_msm8974_1440p_egl_workaround struct {
		Cflags []string
	}
	Bootloader_message_offset struct {
		Cflags []string
	}
	Has_legacy_camera_hal1 struct {
		Cflags []string
		Overrides []string
		Shared_libs []string
	}
	Qcom_um_soong_namespace struct {
		Cflags []string
		Header_libs []string
	}
	Recovery_skip_ev_rel_input struct {
		Cflags []string
	}
	Should_wait_for_qsee struct {
		Cflags []string
	}
	Supports_extended_compress_format struct {
		Cflags []string
	}
	Supports_hw_fde struct {
		Cflags []string
		Header_libs []string
		Shared_libs []string
	}
	Supports_hw_fde_perf struct {
		Cflags []string
	}
	Target_ignores_ftp_pptp_conntrack_failure struct {
		Cppflags []string
	}
	Target_init_vendor_lib struct {
		Whole_static_libs []string
	}
	Target_needs_netd_direct_connect_rule struct {
		Cppflags []string
	}
	Target_process_sdk_version_override struct {
		Cppflags []string
	}
	Target_shim_libs struct {
		Cppflags []string
	}
	Target_surfaceflinger_fod_lib struct {
		Cflags []string
		Whole_static_libs []string
	}
	Uses_generic_camera_parameter_library struct {
		Srcs []string
	}
	Uses_nvidia_enhancements struct {
		Cppflags []string
	}
	Uses_qcom_bsp_legacy struct {
		Cppflags []string
	}
	Uses_qti_camera_device struct {
		Cppflags []string
		Shared_libs []string
	}
}

type ProductVariables struct {
	Additional_gralloc_10_usage_bits  *string `json:",omitempty"`
	Apply_msm8974_1440p_egl_workaround  *bool `json:",omitempty"`
	Bootloader_message_offset  *int `json:",omitempty"`
	Has_legacy_camera_hal1  *bool `json:",omitempty"`
	Qcom_um_soong_namespace  *string `json:",omitempty"`
	Recovery_skip_ev_rel_input  *bool `json:",omitempty"`
	Should_wait_for_qsee  *bool `json:",omitempty"`
	Specific_camera_parameter_library  *string `json:",omitempty"`
	Supports_extended_compress_format  *bool `json:",omitempty"`
	Supports_hw_fde  *bool `json:",omitempty"`
	Supports_hw_fde_perf  *bool `json:",omitempty"`
	Target_ignores_ftp_pptp_conntrack_failure  *bool `json:",omitempty"`
	Target_init_vendor_lib  *string `json:",omitempty"`
	Target_needs_netd_direct_connect_rule  *bool `json:",omitempty"`
	Target_process_sdk_version_override  *string `json:",omitempty"`
	Target_shim_libs  *string `json:",omitempty"`
	Target_specific_header_path  *string `json:",omitempty"`
	Target_surfaceflinger_fod_lib  *string `json:",omitempty"`
	Uses_generic_camera_parameter_library  *bool `json:",omitempty"`
	Uses_nvidia_enhancements  *bool `json:",omitempty"`
	Uses_qcom_bsp_legacy  *bool `json:",omitempty"`
	Uses_qti_camera_device  *bool `json:",omitempty"`
}
