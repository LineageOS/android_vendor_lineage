package android_lineage
type Product_variables struct {
	Needs_text_relocations struct {
		Cppflags []string
	}
	Uses_generic_camera_parameter_library struct {
		Srcs []string
	}
	BoardUsesQTIHardware struct {
		Cflags []string
		Cppflags []string
	}
	BoardUsesQCOMHardware struct {
		Cflags []string
		Cppflags []string
	}
	TargetUsesQCOMBsp struct {
		Cflags []string
		Cppflags []string
	}
	TargetUsesQCOMLegacyBsp struct {
		Cflags []string
		Cppflags []string
	}
	BoardUsesLegacyAlsa struct {
		Cflags []string
		Cppflags []string
	}
}

type ProductVariables struct {
	Uses_generic_camera_parameter_library  *bool `json:",omitempty"`
	Specific_camera_parameter_library  *string `json:",omitempty"`
	Needs_text_relocations  *bool `json:",omitempty"`
	BoardUsesQTIHardware  *bool `json:",omitempty"`
	BoardUsesQCOMHardware  *bool `json:",omitempty"`
	TargetUsesQCOMBsp  *bool `json:",omitempty"`
	TargetUsesQCOMLegacyBsp  *bool `json:",omitempty"`
	BoardUsesLegacyAlsa  *bool `json:",omitempty"`
}
