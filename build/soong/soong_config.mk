# Insert new variables inside the Lineage structure
lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '"Lineage": {'; \
	echo '    "Needs_text_relocations": $(if $(filter true,$(TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS)),true,false)'; \
	echo '    "BTVendorPath": "$(call project-path-for,bt-vendor)",'; \
	echo '    "RILPath": "$(call project-path-for,ril)",'; \
	echo '    "WLANPath": "$(call project-path-for,wlan)",'; \
	echo '},'; \
	echo '"Qualcomm": {'; \
	echo '    "BoardUsesQTIHardware": $(if $(filter true,$(BOARD_USES_QTI_HARDWARE)),true,false)'; \
	echo '    "BoardUsesQCOMHardware": $(if $(filter true,$(BOARD_USES_QCOM_HARDWARE)),true,false)'; \
	echo '    "TargetUsesQCOMBsp": $(if $(filter true,$(TARGET_USES_QCOM_BSP)),true,false)'; \
	echo '    "TargetUsesQCOMLegacyBsp": $(if $(filter true,$(TARGET_USES_QCOM_LEGACY_BSP)),true,false)'; \
	echo '    "BoardUsesLegacyAlsa": $(if $(filter true,$(BOARD_USES_LEGACY_ALSA_AUDIO)),true,false)'; \
	echo '    "QCOMAudioPath": "$(call project-path-for,qcom-audio)",'; \
	echo '    "QCOMCameraPath": "$(call project-path-for,qcom-camera)",'; \
	echo '    "QCOMDataservicesPath": "$(call project-path-for,qcom-dataservices)"';  \
	echo '    "QCOMDisplayPath": "$(call project-path-for,qcom-display)"';  \
	echo '    "QCOMGPSPath": "$(call project-path-for,qcom-gps)"';  \
	echo '    "QCOMMediaPath": "$(call project-path-for,qcom-media)"';  \
	echo '    "QCOMSensorsPath": "$(call project-path-for,qcom-sensors)"';  \
	echo '},'; \
	echo '') > $(SOONG_VARIABLES_TMP)
