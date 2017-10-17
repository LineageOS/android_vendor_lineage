# Permissions for lineage sdk services
PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/org.lineageos.audio.xml:system/etc/permissions/org.lineageos.audio.xml \
    vendor/lineage/config/permissions/org.lineageos.livedisplay.xml:system/etc/permissions/org.lineageos.livedisplay.xml \
    vendor/lineage/config/permissions/org.lineageos.performance.xml:system/etc/permissions/org.lineageos.performance.xml \
    vendor/lineage/config/permissions/org.lineageos.profiles.xml:system/etc/permissions/org.lineageos.profiles.xml \
    vendor/lineage/config/permissions/org.lineageos.statusbar.xml:system/etc/permissions/org.lineageos.statusbar.xml \
    vendor/lineage/config/permissions/org.lineageos.telephony.xml:system/etc/permissions/org.lineageos.telephony.xml \
    vendor/lineage/config/permissions/org.lineageos.weather.xml:system/etc/permissions/org.lineageos.weather.xml

# Lineage Platform Library
PRODUCT_PACKAGES += \
    org.lineageos.platform-res \
    org.lineageos.platform \
    org.lineageos.platform.xml

# Lineage Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.lineageos.hardware \
    org.lineageos.hardware.xml

# JNI Libraries
PRODUCT_PACKAGES += \
    liblineage-sdk_platform_jni

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

# LineageOS Platform SDK Version
PRODUCT_PROPERTY_OVERRIDES += \
  ro.lineage.build.version.plat.sdk=$(LINEAGE_PLATFORM_SDK_VERSION)

# LineageOS Platform Internal
PRODUCT_PROPERTY_OVERRIDES += \
  ro.lineage.build.version.plat.rev=$(LINEAGE_PLATFORM_REV)

