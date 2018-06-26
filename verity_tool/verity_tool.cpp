/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "verity_tool.h"

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <fs_mgr.h>
#include <fec/io.h>
#include <libavb_user/libavb_user.h>

#include <linux/fs.h>

#include <errno.h>

static int make_block_device_writable(const std::string& block_device) {
    int fd = open(block_device.c_str(), O_RDONLY | O_CLOEXEC);
    if (fd < 0) {
        return -errno;
    }

    int OFF = 0;
    int rc = ioctl(fd, BLKROSET, &OFF);
    if (rc < 0) {
        rc = -errno;
        goto out;
    }
    rc = 0;
out:
    close(fd);
    return rc;
}

/* Turn verity on/off */
bool set_block_device_verity_enabled(const std::string& block_device,
        bool enable) {
    int rc = make_block_device_writable(block_device);
    if (rc) {
        LOG(ERROR) << "Could not make block device "
                   << block_device << " writable:" << rc;
        return false;
    }

    fec::io fh(block_device, O_RDWR);
    if (!fh) {
        PLOG(ERROR) << "Could not open block device " << block_device;
        return false;
    }

    fec_verity_metadata metadata;
    if (!fh.get_verity_metadata(metadata)) {
        LOG(ERROR) << "Couldn't find verity metadata!";
        return false;
    }

    if (!enable && metadata.disabled) {
        LOG(ERROR) << "Verity already disabled on " << block_device;
        return false;
    }

    if (enable && !metadata.disabled) {
        LOG(WARNING) << "Verity already enabled on " << block_device;
        return false;
    }

    if (!fh.set_verity_status(enable)) {
        PLOG(ERROR) << "Could not set verity "
                    << (enable ? "enabled" : "disabled")
                    << " flag on device " << block_device;
        return false;
    }

    LOG(DEBUG) << "Verity " << (enable ? "enabled" : "disabled")
               << " on " << block_device;
    return true;
}

/* Helper function to get A/B suffix, if any. If the device isn't
 * using A/B the empty string is returned. Otherwise either "_a",
 * "_b", ... is returned.
 *
 * Note that since sometime in O androidboot.slot_suffix is deprecated
 * and androidboot.slot should be used instead. Since bootloaders may
 * be out of sync with the OS, we check both and for extra safety
 * prepend a leading underscore if there isn't one already.
 */
static std::string get_ab_suffix() {
    std::string ab_suffix = android::base::GetProperty("ro.boot.slot_suffix", "");
    if (ab_suffix.empty()) {
        ab_suffix = android::base::GetProperty("ro.boot.slot", "");
    }
    if (ab_suffix.size() > 0 && ab_suffix[0] != '_') {
        ab_suffix = std::string("_") + ab_suffix;
    }
    return ab_suffix;
}

verity_state_t get_verity_state() {
    verity_state_t rc = VERITY_STATE_NO_DEVICE;
    std::string ab_suffix = get_ab_suffix();

    // Figure out if we're using VB1.0 or VB2.0 (aka AVB) - by
    // contract, androidboot.vbmeta.digest is set by the bootloader
    // when using AVB).
    bool using_avb = !android::base::GetProperty("ro.boot.vbmeta.digest", "").empty();

    if (using_avb) {
        // Yep, the system is using AVB.
        AvbOps* ops = avb_ops_user_new();
        if (ops == nullptr) {
            LOG(ERROR) << "Error getting AVB ops";
            avb_ops_user_free(ops);
            return VERITY_STATE_UNKNOWN;
        }
        bool verity_enabled;
        if (!avb_user_verity_get(ops, ab_suffix.c_str(), &verity_enabled)) {
            LOG(ERROR) << "Error getting verity state";
            avb_ops_user_free(ops);
            return VERITY_STATE_UNKNOWN;
        }
        rc = verity_enabled ? VERITY_STATE_ENABLED : VERITY_STATE_DISABLED;
        avb_ops_user_free(ops);
    } else {
        // Not using AVB - assume VB1.0.

        // read all fstab entries at once from all sources
        struct fstab* fstab = fs_mgr_read_fstab_default();
        if (!fstab) {
            LOG(ERROR) << "Failed to read fstab";
            fs_mgr_free_fstab(fstab);
            return VERITY_STATE_UNKNOWN;
        }

        // Loop through entries looking for ones that vold manages.
        for (int i = 0; i < fstab->num_entries; i++) {
            if (fs_mgr_is_verified(&fstab->recs[i])) {
                std::string block_device = fstab->recs[i].blk_device;
                fec::io fh(block_device, O_RDONLY);
                if (!fh) {
                    PLOG(ERROR) << "Could not open block device " << block_device;
                    rc = VERITY_STATE_UNKNOWN;
                    break;
                }

                fec_verity_metadata metadata;
                if (!fh.get_verity_metadata(metadata)) {
                    LOG(ERROR) << "Couldn't find verity metadata!";
                    rc = VERITY_STATE_UNKNOWN;
                    break;
                }

                rc = metadata.disabled ? VERITY_STATE_DISABLED : VERITY_STATE_ENABLED;
            }
        }
        fs_mgr_free_fstab(fstab);
    }

    return rc;
}

/* Use AVB to turn verity on/off */
static bool set_avb_verity_enabled_state(AvbOps* ops, bool enable_verity) {
    std::string ab_suffix = get_ab_suffix();

    bool verity_enabled;
    if (!avb_user_verity_get(ops, ab_suffix.c_str(), &verity_enabled)) {
        LOG(ERROR) << "Error getting verity state";
        return false;
    }

    if ((verity_enabled && enable_verity) ||
        (!verity_enabled && !enable_verity)) {
        LOG(WARNING) << "verity is already "
                     << verity_enabled ? "enabled" : "disabled";
        return false;
    }

    if (!avb_user_verity_set(ops, ab_suffix.c_str(), enable_verity)) {
        LOG(ERROR) << "Error setting verity";
        return false;
    }

    LOG(DEBUG) << "Successfully " << (enable_verity ? "enabled" : "disabled")
               << " verity";
    return true;
}

bool set_verity_enabled(bool enable) {
    bool rc = true;

    // Do not allow changing verity on user builds
    bool is_user = (android::base::GetProperty("ro.build.type", "") == "user");
    if (is_user) {
        LOG(ERROR) << "Cannot disable verity - USER BUILD";
        return false;
    }

    // Figure out if we're using VB1.0 or VB2.0 (aka AVB) - by
    // contract, androidboot.vbmeta.digest is set by the bootloader
    // when using AVB).
    bool using_avb = !android::base::GetProperty("ro.boot.vbmeta.digest", "").empty();

    // If using AVB, dm-verity is used on any build so we want it to
    // be possible to disable/enable on any build (except USER). For
    // VB1.0 dm-verity is only enabled on certain builds.
    if (using_avb) {
        // Yep, the system is using AVB.
        AvbOps* ops = avb_ops_user_new();
        if (ops == nullptr) {
            LOG(ERROR) << "Error getting AVB ops";
            return false;
        }
        rc = set_avb_verity_enabled_state(ops, enable);
        avb_ops_user_free(ops);
    } else {
        // Not using AVB - assume VB1.0.

        // read all fstab entries at once from all sources
        struct fstab* fstab = fs_mgr_read_fstab_default();
        if (!fstab) {
            LOG(ERROR) << "Failed to read fstab";
            return false;
        }

        // Loop through entries looking for ones that vold manages.
        for (int i = 0; i < fstab->num_entries; i++) {
            if (fs_mgr_is_verified(&fstab->recs[i])) {
                bool result = set_block_device_verity_enabled(
                        fstab->recs[i].blk_device, enable);
                if (!result) {
                    // Warn, but continue if failure occurred
                    LOG(WARNING) << "Failed to set state "
                                 << (enable ? "enabled" : "disabled")
                                 << " on " << fstab->recs[i].mount_point;
                }
                rc = rc && result;
            }
        }
    }

    return rc;
}
