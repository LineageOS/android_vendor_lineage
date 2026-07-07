/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <fs_mgr.h>
#include <liblp/liblp.h>

int main() {
    const auto slot_number = android::fs_mgr::SlotNumberForSlotSuffix(fs_mgr_get_slot_suffix());
    const auto super_device = "/dev/block/by-name/" + fs_mgr_get_super_partition_name();

    auto metadata = android::fs_mgr::ReadMetadata(super_device, slot_number);

    if ((metadata->header.flags & LP_HEADER_FLAG_OVERLAYS_ACTIVE) == 0) {
        printf("OverlayFS is already disabled.\n");
        return 0;
    }

    metadata->header.flags &= ~LP_HEADER_FLAG_OVERLAYS_ACTIVE;

    if (!android::fs_mgr::UpdatePartitionTable(super_device, *metadata, slot_number)) {
        printf("Failed to write metadata.\n");
        return 1;
    }

    printf("OverlayFS has been disabled.\n");

    return 0;
}
