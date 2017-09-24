package android
type Product_variables struct {
	Egl_workaround_bug_10194508 struct {
		Cppflags []string
	}
	Exynos4_enhancements struct {
		Cflags []string
		Cppflags []string
	}
	Needs_text_relocations struct {
		Cppflags []string
	}
}

type ProductVariables struct {
	Egl_workaround_bug_10194508    *bool `json:",omitempty"`
	Exynos4_enhancements    *bool `json:",omitempty"`
	Needs_text_relocations  *bool `json:",omitempty"`
}
