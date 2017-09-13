package android
type Product_variables struct {
	Needs_text_relocations struct {
		Cppflags []string
	}
	BoardUsesQTIHardware struct {
		Cppflags []string
	}
	BoardUsesQCOMHardware struct {
		Cppflags []string
	}
	TargetUsesQCOMBsp struct {
		Cppflags []string
	}
	TargetUsesQCOMLegacyBsp struct {
		Cppflags []string
	}
	BoardUsesLegacyAlsa struct {
		Cppflags []string
	}
}

type ProductVariables struct {
	Needs_text_relocations  *bool `json:",omitempty"`
	BoardUsesQTIHardware  *bool `json:",omitempty"`
	BoardUsesQCOMHardware  *bool `json:",omitempty"`
	TargetUsesQCOMBsp  *bool `json:",omitempty"`
	TargetUsesQCOMLegacyBsp  *bool `json:",omitempty"`
	BoardUsesLegacyAlsa  *bool `json:",omitempty"`
}
