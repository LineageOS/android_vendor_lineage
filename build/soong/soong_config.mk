LINEAGE_SOONG_VARIABLES_TMP := $(shell mktemp -u)

lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '') > $(SOONG_VARIABLES_TMP)
