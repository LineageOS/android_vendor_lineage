# Target-specific configuration

# Bring in Qualcomm helper macros
include vendor/lineage/build/core/qcom_utils.mk

# Populate the qcom hardware variants in the project pathmap.
define ril-set-path-variant
$(call project-set-path-variant,ril,TARGET_RIL_VARIANT,hardware/$(1))
endef
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
    UM_FAMILY := msm8937 msm8953

    BOARD_USES_ADRENO := true

    TARGET_USES_QCOM_BSP := true

    # Tell HALs that we're compiling an AOSP build with an in-line kernel
    TARGET_COMPILE_WITH_MSM_KERNEL := true

    ifneq ($(filter msm7x27a msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
        # Enable legacy audio functions
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            USE_CUSTOM_AUDIO_POLICY := 1
        endif
    endif

    # Allow building audio encoders
    TARGET_USES_QCOM_MM_AUDIO := true

    # Enable color metadata for modern UM targets
    ifneq ($(filter msm8996 msm8998 sdm660,$(TARGET_BOARD_PLATFORM)),)
        TARGET_USES_COLOR_METADATA := true
    endif

    # List of targets that use master side content protection
    MASTER_SIDE_CP_TARGET_LIST := msm8996 msm8998 sdm660

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
    ifeq ($(call is-board-platform-in-list, $(UM_FAMILY)),true)
        MSM_VIDC_TARGET_LIST := $(UM_FAMILY)
        QCOM_HARDWARE_VARIANT := msm8937
    else
        MSM_VIDC_TARGET_LIST := $(TARGET_BOARD_PLATFORM)
        QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
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

$(call ril-set-path-variant,ril)
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

$(call ril-set-path-variant,ril)
$(call wlan-set-path-variant,wlan)
$(call bt-vendor-set-path-variant,bt)

endif
