# Insert new variables inside the Lineage structure
lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '"Lineage": {'; \
	echo '    "Needs_text_relocations": $(if $(filter true,$(TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS)),true,false),'; \
	echo '    "Uses_non_treble_camera": $(if $(filter true,$(TARGET_USES_NON_TREBLE_CAMERA)),true,false)'; \
	echo '},'; \
	echo '') > $(SOONG_VARIABLES_TMP)
