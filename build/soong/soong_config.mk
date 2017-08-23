lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '') > $(SOONG_VARIABLES_TMP)
