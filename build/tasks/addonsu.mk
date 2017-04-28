ADDONSU_PREBUILTS_PATH := vendor/cm/addonsu/

ADDONSU_INSTALL_OUT := $(PRODUCT_OUT)/addonsu-install/
ADDONSU_INSTALL_TARGET := $(PRODUCT_OUT)/addonsu-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_ARCH).zip

$(ADDONSU_INSTALL_TARGET): $(ALL_MODULES.updater.BUILT) \
		$(ALL_MODULES.su.BUILT) $(ALL_MODULES.su.PATH)/superuser.rc
	$(hide) rm -rf $@ $(ADDONSU_INSTALL_OUT)
	$(hide) mkdir -p $(ADDONSU_INSTALL_OUT)/META-INF/com/google/android/
	$(hide) mkdir -p $(ADDONSU_INSTALL_OUT)/system/xbin
	$(hide) mkdir -p $(ADDONSU_INSTALL_OUT)/system/addon.d
	$(hide) mkdir -p $(ADDONSU_INSTALL_OUT)/system/etc/init
	$(hide) cp $(ALL_MODULES.su.BUILT) $(ADDONSU_INSTALL_OUT)/system/xbin/
	$(hide) cp $(ALL_MODULES.su.PATH)/superuser.rc $(ADDONSU_INSTALL_OUT)/system/etc/init/
	$(hide) cp $(ALL_MODULES.updater.BUILT) $(ADDONSU_INSTALL_OUT)/META-INF/com/google/android/update-binary
	$(hide) cp $(ADDONSU_PREBUILTS_PATH)/51-addonsu.sh $(ADDONSU_INSTALL_OUT)/system/addon.d/
	$(hide) cp $(ADDONSU_PREBUILTS_PATH)/mount-system.sh $(ADDONSU_INSTALL_OUT)/
	$(hide) cp $(ADDONSU_PREBUILTS_PATH)/updater-script-install $(ADDONSU_INSTALL_OUT)/META-INF/com/google/android/updater-script
	$(hide) (cd $(ADDONSU_INSTALL_OUT) && zip -qr $@ *)

.PHONY: addonsu
addonsu: $(ADDONSU_INSTALL_TARGET)
	@echo "Done: $(ADDONSU_INSTALL_TARGET)"


ADDONSU_REMOVE_OUT := $(PRODUCT_OUT)/addonsu-remove/
ADDONSU_REMOVE_TARGET := $(PRODUCT_OUT)/addonsu-remove-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_ARCH).zip

$(ADDONSU_REMOVE_TARGET): $(ALL_MODULES.updater.BUILT)
	$(hide) rm -rf $@ $(ADDONSU_REMOVE_OUT)
	$(hide) mkdir -p $(ADDONSU_REMOVE_OUT)/META-INF/com/google/android/
	$(hide) cp $(ALL_MODULES.updater.BUILT) $(ADDONSU_REMOVE_OUT)/META-INF/com/google/android/update-binary
	$(hide) cp $(ADDONSU_PREBUILTS_PATH)/mount-system.sh $(ADDONSU_REMOVE_OUT)/
	$(hide) cp $(ADDONSU_PREBUILTS_PATH)/updater-script-remove $(ADDONSU_REMOVE_OUT)/META-INF/com/google/android/updater-script
	$(hide) (cd $(ADDONSU_REMOVE_OUT) && zip -qr $@ *)

.PHONY: addonsu-remove
addonsu-remove: $(ADDONSU_REMOVE_TARGET)
	@echo "Done: $(ADDONSU_REMOVE_TARGET)"
