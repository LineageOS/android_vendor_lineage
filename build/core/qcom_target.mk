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

$(call set-device-specific-path,AUDIO,audio,hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/audio)
$(call set-device-specific-path,DISPLAY,display,hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/display)
$(call set-device-specific-path,MEDIA,media,hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/media)

$(call set-device-specific-path,BT_VENDOR,bt-vendor,hardware/qcom-caf/bt)
$(call set-device-specific-path,CAMERA,camera,hardware/qcom-caf/camera)
$(call set-device-specific-path,DATA_IPA_CFG_MGR,data-ipa-cfg-mgr,vendor/qcom/opensource/data-ipa-cfg-mgr)
$(call set-device-specific-path,GPS,gps,hardware/qcom-caf/gps)
$(call set-device-specific-path,SENSORS,sensors,hardware/qcom-caf/sensors)
$(call set-device-specific-path,LOC_API,loc-api,vendor/qcom/opensource/location)
$(call set-device-specific-path,DATASERVICES,dataservices,vendor/qcom/opensource/dataservices)
$(call set-device-specific-path,POWER,power,hardware/qcom-caf/power)
$(call set-device-specific-path,THERMAL,thermal,hardware/qcom-caf/thermal)
$(call set-device-specific-path,VR,vr,hardware/qcom-caf/vr)
$(call set-device-specific-path,WLAN,wlan,hardware/qcom-caf/wlan)

PRODUCT_CFI_INCLUDE_PATHS += \
    hardware/qcom-caf/wlan/qcwcn/wpa_supplicant_8_lib
else

$(call project-set-path,qcom-audio,hardware/qcom/audio)
$(call project-set-path,qcom-display,hardware/qcom/display/$(TARGET_BOARD_PLATFORM))
$(call project-set-path,qcom-media,hardware/qcom/media/$(TARGET_BOARD_PLATFORM))

$(call project-set-path,qcom-bt-vendor,hardware/qcom/bt)
$(call project-set-path,qcom-camera,hardware/qcom/camera)
$(call project-set-path,qcom-data-ipa-cfg-mgr,hardware/qcom/data/ipacfg-mgr)
$(call project-set-path,qcom-gps,hardware/qcom/gps)
$(call project-set-path,qcom-sensors,hardware/qcom/sensors)
$(call project-set-path,qcom-loc-api,vendor/qcom/opensource/location)
$(call project-set-path,qcom-dataservices,$(TARGET_DEVICE_DIR)/dataservices)
$(call project-set-path,qcom-wlan,hardware/qcom/wlan)

endif
