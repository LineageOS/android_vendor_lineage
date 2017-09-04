# Insert new variables above "Needs_text_relocations"
lineage_soong:
	$(hide) mkdir -p $(dir $@)
	$(hide) (\
	echo '{'; \
	echo '"Lineage": {'; \
	echo '},'; \
	echo '') > $(SOONG_VARIABLES_TMP)
