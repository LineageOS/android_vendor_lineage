SOONG_CONFIG_NAMESPACES += lineageVarsPlugin

SOONG_CONFIG_lineageVarsPlugin :=

# Add variables that we wish to make available in soong here.

# Kernel
SOONG_CONFIG_lineageVarsPlugin += kernelSource kernelConfig
SOONG_CONFIG_lineageVarsPlugin_kernelSource := $(TARGET_KERNEL_SOURCE)
SOONG_CONFIG_lineageVarsPlugin_kernelConfig := $(TARGET_KERNEL_CONFIG)
