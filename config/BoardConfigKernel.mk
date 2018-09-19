SOONG_CONFIG_NAMESPACES += generatedKernelPlugin

SOONG_CONFIG_generatedKernelPlugin := path config clang
SOONG_CONFIG_generatedKernelPlugin_path := $(TARGET_KERNEL_SOURCE)
SOONG_CONFIG_generatedKernelPlugin_config := $(TARGET_KERNEL_CONFIG)
SOONG_CONFIG_generatedKernelPlugin_clang := $(TARGET_KERNEL_CLANG_COMPILE)
