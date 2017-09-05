package android
type Product_variables struct {
	Needs_text_relocations struct {
		Cppflags []string
	}

	Uses_non_treble_camera struct {
		Cflags []string
	}
}

type ProductVariables struct {
	Needs_text_relocations  *bool `json:",omitempty"`
	Uses_non_treble_camera  *bool `json:",omitempty"`
}
