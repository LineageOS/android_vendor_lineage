<<<<<<< HEAD   (e6a75b apn: Update mcc525)
=======
# Inherit full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full.mk)

# Required packages
PRODUCT_PACKAGES += \
    androidx.window.extensions \
    LatinIME

# Include Lineage LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/lineage/overlay/dictionaries
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/lineage/overlay/dictionaries

$(call inherit-product, vendor/lineage/config/telephony.mk)
>>>>>>> CHANGE (33fe58 config: Exclude LatinIME dictionaries from RRO overlays)
