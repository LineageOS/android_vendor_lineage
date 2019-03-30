ifeq ($(WITH_GMS),true)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
#ifeq ($(TARGET_ARCH),arm64)
$(call inherit-product-if-exists, vendor/partner_gms/products/turbo.mk)
#endif
endif
