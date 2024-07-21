# Inherit mobile mini common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile_mini.mk)

# Inherit tablet common Lineage stuff
$(call inherit-product, vendor/lineage/config/tablet.mk)

$(call inherit-product, vendor/lineage/config/telephony.mk)
