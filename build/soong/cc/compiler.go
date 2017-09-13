package cc
func (compiler *baseCompiler) compilerFlagsLineage {
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
}
