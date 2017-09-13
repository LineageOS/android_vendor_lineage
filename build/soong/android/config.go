package android_lineage

import (
	"android/soong/android"

	"github.com/google/blueprint/proptools"
)

var Bool = proptools.Bool

func (c *android.deviceConfig) BoardUsesQTIHardware() bool {
	return Bool(c.config.ProductVariables.BoardUsesQTIHardware)
}

func (c *android.deviceConfig) BoardUsesQCOMHardware() bool {
	return Bool(c.config.ProductVariables.BoardUsesQCOMHardware)
}

func (c *android.deviceConfig) TargetUsesQCOMBsp() bool {
	return Bool(c.config.ProductVariables.TargetUsesQCOMBsp)
}

func (c *android.deviceConfig) TargetUsesQCOMLegacyBsp() bool {
	return Bool(c.config.ProductVariables.TargetUsesQCOMLegacyBsp)
}

func (c *android.deviceConfig) BoardUsesLegacyAlsa() bool {
	return Bool(c.config.ProductVariables.BoardUsesLegacyAlsa)
}
