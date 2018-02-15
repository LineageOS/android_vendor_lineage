# Insert new variables inside the Lineage structure
lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '"Lineage": {'; \
	echo '    "Uses_generic_camera_parameter_library": $(if $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY),false,true),'; \
	echo '    "Specific_camera_parameter_library": "$(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY)",'; \
	echo '    "Needs_text_relocations": $(if $(filter true,$(TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS)),true,false),'; \
	echo '    "Uses_qcom_bsp_legacy": $(if $(filter true,$(TARGET_USES_QCOM_BSP_LEGACY)),true,false),'; \
	echo '    "Target_shim_libs": "$(TARGET_LD_SHIM_LIBS)"'; \
	echo '},'; \
	echo '') > $(SOONG_VARIABLES_TMP)
