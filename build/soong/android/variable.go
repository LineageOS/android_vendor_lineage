package android
type Product_variables struct {
	Needs_text_relocations struct {
		Cppflags []string
	}
	BoardUsesQTIHardware struct {
		Cppflags []string -DQTI_HARDWARE
		Cflags []string -DQTI_HARDWARE
	}
	BoardUsesQCOMHardware struct {
		Cppflags []string -DQCOM_HARDWARE
		Cflags []string -DQCOM_HARDWARE
	}
	TargetUsesQCOMBsp struct {
		Cppflags []string -DQCOM_BSP -DQTI_BSP
		Cflags []string -DQCOM_BSP -DQTI_BSP
	}
	TargetUsesQCOMLegacyBsp struct {
		Cppflags []string -DQCOM_BSP_LEGACY
		Cflags []string -DQCOM_BSP_LEGACY
	}
	BoardUsesLegacyAlsa struct {
		Cppflags []string -DLEGACY_ALSA_AUDIO
		Cflags []string -DLEGACY_ALSA_AUDIO
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
