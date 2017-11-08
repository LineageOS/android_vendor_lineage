package android
type Product_variables struct {
	Needs_text_relocations struct {
		Cppflags []string
	}
}

type ProductVariables struct {
	Linker_forced_shim_libs  *string `json:",omitempty"`
	Needs_text_relocations  *bool `json:",omitempty"`
}
