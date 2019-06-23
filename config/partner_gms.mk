ifeq ($(WITH_GMS),true)
ifneq ($(call math_lt,1700000000,$(BOARD_SYSTEMIMAGE_PARTITION_SIZE)),)
WITH_GMS_MINIMAL := true
ifeq ($(WITH_GMS_FI),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/fi.mk)
else
ifeq ($(WITH_GMS_MINIMAL),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_minimal.mk)
else
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
endif
endif
endif
