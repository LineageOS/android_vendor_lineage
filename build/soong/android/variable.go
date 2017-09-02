package android
type Product_variables struct {
	Has_legacy_camera_hal1 struct {
		Cflags []string
	}

	Uses_media_extensions struct {
		Cflags []string
	}

	Needs_text_relocations struct {
		Cppflags []string
	}

	Mtk_hardware struct {
		Cflags []string
	}

        Device_recovery_modules struct {
                Cflags []string
        }

        Pre_ion_x86 struct {
                Cflags []string
        }
}

type ProductVariables struct {
	Has_legacy_camera_hal1  *bool `json:",omitempty"`
	Uses_media_extensions   *bool `json:",omitempty"`
	Needs_text_relocations  *bool `json:",omitempty"`
	Mtk_hardware            *bool `json:",omitempty"`
	Device_recovery_modules *bool `json:",omitempty"`
	Pre_ion_x86             *bool `json:",omitempty"`
}
