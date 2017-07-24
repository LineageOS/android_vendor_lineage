LINEAGE_SOONG_VARIABLES_TMP := $(shell mktemp -u)

lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '      "Has_legacy_camera_hal1": $(if $(filter true,$(TARGET_HAS_LEGACY_CAMERA_HAL1)),true,false),'; \
	echo '') > $(SOONG_VARIABLES_TMP)
