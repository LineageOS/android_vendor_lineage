lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '    "Has_legacy_camera_hal1": $(if $(filter true,$(TARGET_HAS_LEGACY_CAMERA_HAL1)),true,false),'; \
	echo '    "Uses_media_extensions": $(if $(filter true,$(TARGET_USES_MEDIA_EXTENSIONS)),true,false),'; \
	echo '    "Needs_text_relocations": $(if $(filter true,$(TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS)),true,false),'; \
	echo '    "Mtk_hardware": $(if $(filter true,$(BOARD_USES_MTK_HARDWARE)),true,false),'; \
        echo '    "Device_recovery_modules":$(if $(filter true,$(TARGET_RECOVERY_DEVICE_MODULES)),true,false),'; \
        echo '    "Pre_ion_x86":$(if $(filter true,$(BOARD_USES_PRE_ION_X86)),true,false),'; \
	echo '') > $(SOONG_VARIABLES_TMP)
