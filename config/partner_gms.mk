ifeq ($(WITH_GMS),true)
<<<<<<< HEAD   (d780ff roomservice: support new manifest formats.)
=======
ifeq ($(PRODUCT_IS_ATV),true)
$(call inherit-product-if-exists, vendor/partner_gms-tv/products/gms.mk)
else
ifeq ($(WITH_GMS_FI),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/fi.mk)
else
ifeq ($(WITH_GMS_MINIMAL),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_minimal.mk)
else
>>>>>>> CHANGE (2a621b partner_gms: Support TV GMS)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
<<<<<<< HEAD   (d780ff roomservice: support new manifest formats.)
=======
endif
endif
endif
>>>>>>> CHANGE (2a621b partner_gms: Support TV GMS)
