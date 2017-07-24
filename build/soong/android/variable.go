package android
type Product_variables struct {
	Has_legacy_camera_hal1 struct {
		Cflags []string
	}

	Needs_text_relocations struct {
		Cppflags []string
	}

	Uses_non_treble_camera struct {
		Cflags []string
	}
}

type ProductVariables struct {
	Has_legacy_camera_hal1  *bool `json:",omitempty"`
	Needs_text_relocations  *bool `json:",omitempty"`
	Uses_non_treble_camera  *bool `json:",omitempty"`
}
