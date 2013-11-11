#
# This policy configuration will be used by all products that
# inherit from CM
#

BOARD_SEPOLICY_DIRS += \
    vendor/cm/sepolicy

BOARD_SEPOLICY_UNION += \
    file_contexts \
    fs_use \
    seapp_contexts \
    mac_permissions.xml
