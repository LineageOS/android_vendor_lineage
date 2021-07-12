ifeq ($(WITH_GMS),true)
ifeq ($(WITH_GMS_TV),true)
$(call inherit-product-if-exists, vendor/partner_gms-tv/products/gms.mk)
else ifeq ($(WITH_GMS_FI),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/fi.mk)
else ifeq ($(WITH_GMS_GO),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_go.mk)
else ifeq ($(WITH_GMS_GO_2GB),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_go_2gb.mk)
else ifeq ($(WITH_GMS_MINIMAL),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_minimal.mk)
else
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
endif
