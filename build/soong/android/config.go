package android

// Global config used by Lineage soong additions
var LineageConfig = struct {
	JavaSourcesOverlayModuleWhitelist []string
}{
	[]string{
		// List of packages that are permitted
		// for java sources overlay.
		"org.lineageos.hardware",
	},
}
