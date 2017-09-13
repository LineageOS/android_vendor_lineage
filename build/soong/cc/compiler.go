package cc

import (
	"github.com/google/blueprint/proptools"
)

var Bool = proptools.Bool

type ModuleContextIntf interface {
	static() bool
	staticBinary() bool
	clang() bool
	toolchain() config.Toolchain
	noDefaultCompilerFlags() bool
	sdk() bool
	sdkVersion() string
	vndk() bool
	createVndkSourceAbiDump() bool
	selectedStl() string
	baseModuleName() string
}

type ModuleContext interface {
	android.ModuleContext
	ModuleContextIntf
}

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

func (compiler *baseCompiler) compilerFlagsLineage(ctx ModuleContext, flags Flags) Flags {
  if (Bool(ctx.AConfig().ProductVariables.BoardUsesQTIHardware)) {
    flags.CppFlags = append(flags.CppFlags, "-DQTI_HARDWARE")
  }
  if (Bool(ctx.AConfig().ProductVariables.BoardUsesQCOMHardware)) {
    flags.CppFlags = append(flags.CppFlags, "-DQCOM_HARDWARE")
  }
  if (Bool(ctx.AConfig().ProductVariables.TargetUsesQCOMBsp)) {
    flags.CppFlags = append(flags.CppFlags, "-DQCOM_BSP")
    flags.CppFlags = append(flags.CppFlags, "-DQTI_BSP")
  }
  if (Bool(ctx.AConfig().ProductVariables.TargetUsesQCOMLegacyBsp)) {
    flags.CppFlags = append(flags.CppFlags, "-DQCOM_BSP_LEGACY")
  }
  if (Bool(ctx.AConfig().ProductVariables.BoardUsesLegacyAlsa)) {
    flags.CppFlags = append(flags.CppFlags, "-DLEGACY_ALSA_AUDIO")
  }

  return flags
}
