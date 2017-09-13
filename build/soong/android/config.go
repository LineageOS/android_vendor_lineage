package android_lineage

import (
	"github.com/google/blueprint/proptools"
)

var Bool = proptools.Bool

func (c *deviceConfig) BoardUsesQTIHardware() bool {
	return Bool(c.config.ProductVariables.BoardUsesQTIHardware)
}

func (c *deviceConfig) BoardUsesQCOMHardware() bool {
	return Bool(c.config.ProductVariables.BoardUsesQCOMHardware)
}

func (c *deviceConfig) TargetUsesQCOMBsp() bool {
	return Bool(c.config.ProductVariables.TargetUsesQCOMBsp)
}

func (c *deviceConfig) TargetUsesQCOMLegacyBsp() bool {
	return Bool(c.config.ProductVariables.TargetUsesQCOMLegacyBsp)
}

func (c *deviceConfig) BoardUsesLegacyAlsa() bool {
	return Bool(c.config.ProductVariables.BoardUsesLegacyAlsa)
}
