# Inherit mobile full common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile_full.mk)

# Inherit full tablet common Lineage stuff
$(call inherit-product, vendor/lineage/config/full_tablet.mk)

$(call inherit-product, vendor/lineage/config/telephony.mk)
