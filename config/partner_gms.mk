ifeq ($(WITH_GMS),true)
ifeq ($(WITH_GMS_FI),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/fi.mk)
else
ifneq ($(filter 1, $(shell echo $$(($(BOARD_SYSTEMIMAGE_PARTITION_SIZE) < 1700000)))),)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_minimal.mk)
else
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
endif
endif
