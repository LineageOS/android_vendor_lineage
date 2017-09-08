# Permissions for lineagesdk services
PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/org.cyanogenmod.audio.xml:system/etc/permissions/org.cyanogenmod.audio.xml \
    vendor/lineage/config/permissions/org.cyanogenmod.livedisplay.xml:system/etc/permissions/org.cyanogenmod.livedisplay.xml \
    vendor/lineage/config/permissions/org.cyanogenmod.performance.xml:system/etc/permissions/org.cyanogenmod.performance.xml \
    vendor/lineage/config/permissions/org.cyanogenmod.profiles.xml:system/etc/permissions/org.cyanogenmod.profiles.xml \
    vendor/lineage/config/permissions/org.cyanogenmod.statusbar.xml:system/etc/permissions/org.cyanogenmod.statusbar.xml \
    vendor/lineage/config/permissions/org.cyanogenmod.telephony.xml:system/etc/permissions/org.cyanogenmod.telephony.xml \
    vendor/lineage/config/permissions/org.cyanogenmod.weather.xml:system/etc/permissions/org.cyanogenmod.weather.xml

# CM Platform Library
PRODUCT_PACKAGES += \
    org.cyanogenmod.platform-res \
    org.cyanogenmod.platform \
    org.cyanogenmod.platform.xml

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# JNI Libraries
PRODUCT_PACKAGES += \
    liblineagesdk_platform_jni

ifndef LINEAGE_PLATFORM_SDK_VERSION
  # This is the canonical definition of the SDK version, which defines
  # the set of APIs and functionality available in the platform.  It
  # is a single integer that increases monotonically as updates to
  # the SDK are released.  It should only be incremented when the APIs for
  # the new release are frozen (so that developers don't write apps against
  # intermediate builds).
  LINEAGE_PLATFORM_SDK_VERSION := 7
endif

ifndef LINEAGE_PLATFORM_REV
  # For internal SDK revisions that are hotfixed/patched
  # Reset after each LINEAGE_PLATFORM_SDK_VERSION release
  # If you are doing a release and this is NOT 0, you are almost certainly doing it wrong
  LINEAGE_PLATFORM_REV := 0
endif

# CyanogenMod Platform SDK Version
PRODUCT_PROPERTY_OVERRIDES += \
  ro.lineage.build.version.plat.sdk=$(LINEAGE_PLATFORM_SDK_VERSION)

# CyanogenMod Platform Internal
PRODUCT_PROPERTY_OVERRIDES += \
  ro.lineage.build.version.plat.rev=$(LINEAGE_PLATFORM_REV)

