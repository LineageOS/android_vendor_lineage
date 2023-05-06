# Inherit common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mobile.mk)

PRODUCT_SIZE := full

# Include {Lato,Rubik} fonts
$(call inherit-product-if-exists, external/google-fonts/lato/fonts.mk)
$(call inherit-product-if-exists, external/google-fonts/rubik/fonts.mk)

<<<<<<< HEAD   (b5bce5 roomservice: Read all local manifests)
=======
# Extra cmdline tools
PRODUCT_PACKAGES += \
    unrar \
    zstd

>>>>>>> CHANGE (055bec config: common-full: unrar undead)
# Fonts
PRODUCT_PACKAGES += \
    fonts_customization.xml \
    FontLatoOverlay \
    FontRubikOverlay

# Recorder
PRODUCT_PACKAGES += \
    Recorder
