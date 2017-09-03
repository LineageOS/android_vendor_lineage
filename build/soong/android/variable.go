package android
type Product_variables struct {
	Exynos4_enhancements struct {
		Cflags []string
		Cppflags []string
	}
	Needs_text_relocations struct {
		Cppflags []string
	}
}

type ProductVariables struct {
	Exynos4_enhancements    *bool `json:",omitempty"`
	Needs_text_relocations  *bool `json:",omitempty"`
}
