# Target-specific configuration

# Bring in Qualcomm helper macros
include vendor/lineage/build/core/qcom_utils.mk

define wlan-set-path-variant
$(call project-set-path-variant,wlan,TARGET_WLAN_VARIANT,hardware/qcom/$(1))
endef
define bt-vendor-set-path-variant
$(call project-set-path-variant,bt-vendor,TARGET_BT_VENDOR_VARIANT,hardware/qcom/$(1))
endef

# Set device-specific HALs into project pathmap
define set-device-specific-path
$(if $(USE_DEVICE_SPECIFIC_$(1)), \
    $(if $(DEVICE_SPECIFIC_$(1)_PATH), \
        $(eval path := $(DEVICE_SPECIFIC_$(1)_PATH)), \
        $(eval path := $(TARGET_DEVICE_DIR)/$(2))), \
    $(eval path := $(3))) \
$(call project-set-path,qcom-$(2),$(strip $(path)))
endef

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
    B_FAMILY := msm8226 msm8610 msm8974
    B64_FAMILY := msm8992 msm8994
    BR_FAMILY := msm8909 msm8916
    UM_3_18_FAMILY := msm8937 msm8953 msm8996
    UM_4_4_FAMILY := msm8998 sdm660
    UM_4_9_FAMILY := sdm710 sdm845
    UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY)

    BOARD_USES_ADRENO := true

    # UM platforms no longer need this set on O+
    ifneq ($(call is-board-platform-in-list, $(UM_PLATFORMS)),true)
        TARGET_USES_QCOM_BSP := true
    endif

    # Tell HALs that we're compiling an AOSP build with an in-line kernel
    TARGET_COMPILE_WITH_MSM_KERNEL := true

    ifneq ($(filter msm7x27a msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
        TARGET_USES_QCOM_BSP_LEGACY := true
        # Enable legacy audio functions
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            USE_CUSTOM_AUDIO_POLICY := 1
        endif
    endif

    # Enable media extensions
    TARGET_USES_MEDIA_EXTENSIONS := true

    # Allow building audio encoders
    TARGET_USES_QCOM_MM_AUDIO := true

    # Enable color metadata for every UM platform
    ifeq ($(call is-board-platform-in-list, $(UM_PLATFORMS)),true)
        TARGET_USES_COLOR_METADATA := true
    endif

    # Enable DRM PP driver on UM platforms that support it
    ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY)),true)
        TARGET_USES_DRM_PP := true
    endif

    # List of targets that use master side content protection
    MASTER_SIDE_CP_TARGET_LIST := msm8996 msm8998 sdm660 sdm710 sdm845

    ifeq ($(call is-board-platform-in-list, $(B_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(B_FAMILY)
        QCOM_HARDWARE_VARIANT := msm8974
    else
    ifeq ($(call is-board-platform-in-list, $(B64_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(B64_FAMILY)
        QCOM_HARDWARE_VARIANT := msm8994
    else
    ifeq ($(call is-board-platform-in-list, $(BR_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(BR_FAMILY)
        QCOM_HARDWARE_VARIANT := msm8916
    else
    ifeq ($(call is-board-platform-in-list, $(UM_3_18_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(UM_3_18_FAMILY)
        QCOM_HARDWARE_VARIANT := msm8996
    else
    ifeq ($(call is-board-platform-in-list, $(UM_4_4_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(UM_4_4_FAMILY)
        QCOM_HARDWARE_VARIANT := msm8998
    else
    ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(UM_4_9_FAMILY)
        QCOM_HARDWARE_VARIANT := sdm845
    else
        MSM_VIDC_TARGET_LIST := $(TARGET_BOARD_PLATFORM)
        QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
    endif
    endif
    endif
    endif
    endif
    endif

$(call set-device-specific-path,AUDIO,audio,hardware/qcom/audio-caf/$(QCOM_HARDWARE_VARIANT))
$(call set-device-specific-path,DISPLAY,display,hardware/qcom/display-caf/$(QCOM_HARDWARE_VARIANT))
$(call set-device-specific-path,MEDIA,media,hardware/qcom/media-caf/$(QCOM_HARDWARE_VARIANT))

$(call set-device-specific-path,CAMERA,camera,hardware/qcom/camera)
$(call set-device-specific-path,GPS,gps,hardware/qcom/gps)
$(call set-device-specific-path,SENSORS,sensors,hardware/qcom/sensors)
$(call set-device-specific-path,LOC_API,loc-api,vendor/qcom/opensource/location)
$(call set-device-specific-path,DATASERVICES,dataservices,vendor/qcom/opensource/dataservices)
$(call set-device-specific-path,POWER,power,hardware/qcom/power)
$(call set-device-specific-path,THERMAL,thermal,hardware/qcom/thermal)
$(call set-device-specific-path,VR,vr,hardware/qcom/vr)

$(call wlan-set-path-variant,wlan-caf)
$(call bt-vendor-set-path-variant,bt-caf)

else

$(call project-set-path,qcom-audio,hardware/qcom/audio/default)
$(call project-set-path,qcom-display,hardware/qcom/display/$(TARGET_BOARD_PLATFORM))
$(call project-set-path,qcom-media,hardware/qcom/media/$(TARGET_BOARD_PLATFORM))

$(call project-set-path,qcom-camera,hardware/qcom/camera)
$(call project-set-path,qcom-gps,hardware/qcom/gps)
$(call project-set-path,qcom-sensors,hardware/qcom/sensors)
$(call project-set-path,qcom-loc-api,vendor/qcom/opensource/location)
$(call project-set-path,qcom-dataservices,$(TARGET_DEVICE_DIR)/dataservices)

$(call wlan-set-path-variant,wlan)
$(call bt-vendor-set-path-variant,bt)

endif
