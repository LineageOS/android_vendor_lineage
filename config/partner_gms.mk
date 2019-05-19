ifeq ($(WITH_GMS),true)
ifeq ($(WITH_GMS_FI),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/fi.mk)
else
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
endif
