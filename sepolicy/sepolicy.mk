#
# This policy configuration will be used by all products that
# inherit from CM
#

BOARD_SEPOLICY_DIRS += \
    vendor/cm/sepolicy

BOARD_SEPOLICY_UNION += \
    file.te \
    file_contexts \
    genfs_contexts \
    property_contexts \
    seapp_contexts \
    service_contexts \
    adbd.te \
    app.te \
    auditd.te \
    bootanim.te \
    drmserver.te \
    healthd.te \
    hostapd.te \
    installd.te \
    mediaserver.te \
    netd.te \
    property.te \
    recovery.te \
    shell.te \
    su.te \
    sysinit.te \
    system.te \
    system_app.te \
    system_server.te \
    ueventd.te \
    uncrypt.te \
    userinit.te \
    vold.te \
    zygote.te \
    mac_permissions.xml
