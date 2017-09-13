package cc_lineage

import (
	"lineage/soong/android_lineage"

	"github.com/google/blueprint/proptools"
)

var Bool = proptools.Bool

type Flags struct {
	GlobalFlags []string // Flags that apply to C, C++, and assembly source files
	ArFlags     []string // Flags that apply to ar
	AsFlags     []string // Flags that apply to assembly source files
	CFlags      []string // Flags that apply to C and C++ source files
	ConlyFlags  []string // Flags that apply to C source files
	CppFlags    []string // Flags that apply to C++ source files
	YaccFlags   []string // Flags that apply to Yacc source files
	protoFlags  []string // Flags that apply to proto source files
	aidlFlags   []string // Flags that apply to aidl source files
	LdFlags     []string // Flags that apply to linker command lines
	libFlags    []string // Flags to add libraries early to the link order
	TidyFlags   []string // Flags that apply to clang-tidy
	SAbiFlags   []string // Flags that apply to header-abi-dumper
	YasmFlags   []string // Flags that apply to yasm assembly source files

	// Global include flags that apply to C, C++, and assembly source files
	// These must be after any module include flags, which will be in GlobalFlags.
	SystemIncludeFlags []string

	Toolchain config.Toolchain
	Clang     bool
	Tidy      bool
	Coverage  bool
	SAbiDump  bool

	RequiredInstructionSet string
	DynamicLinker          string

	CFlagsDeps android.Paths // Files depended on by compiler flags

	GroupStaticLibs bool
}

func (compiler *baseCompiler) compilerFlagsLineage(flags Flags) Flags {
  if (Bool(android_lineage.ProductVariables.BoardUsesQTIHardware)) {
    flags.CppFlags = append(flags.CppFlags, "-DQTI_HARDWARE")
  }
  if (Bool(android_lineage.ProductVariables.BoardUsesQCOMHardware)) {
    flags.CppFlags = append(flags.CppFlags, "-DQCOM_HARDWARE")
  }
  if (Bool(android_lineage.ProductVariables.TargetUsesQCOMBsp)) {
    flags.CppFlags = append(flags.CppFlags, "-DQCOM_BSP")
    flags.CppFlags = append(flags.CppFlags, "-DQTI_BSP")
  }
  if (Bool(android_lineage.ProductVariables.TargetUsesQCOMLegacyBsp)) {
    flags.CppFlags = append(flags.CppFlags, "-DQCOM_BSP_LEGACY")
  }
  if (Bool(android_lineage.ProductVariables.BoardUsesLegacyAlsa)) {
    flags.CppFlags = append(flags.CppFlags, "-DLEGACY_ALSA_AUDIO")
  }

  return flags
}
