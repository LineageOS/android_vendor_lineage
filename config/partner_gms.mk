ifeq ($(WITH_GMS),true)
ifeq ($(PRODUCT_IS_ATV),true)
$(call inherit-product-if-exists, vendor/partner_gms-tv/products/gms.mk)
else
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
endif
