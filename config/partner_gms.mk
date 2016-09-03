ifeq ($(WITH_GMS),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
