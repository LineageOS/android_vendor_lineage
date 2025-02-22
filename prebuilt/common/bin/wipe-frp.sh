#!/system/bin/sh
#
# SPDX-FileCopyrightText: 2025 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

FRP_BLOCK=$(getprop ro.frp.pst)

if [[ -z "${FRP_BLOCK}" ]]; then
    echo "frp prop not set"
    exit -1
fi

FRP_BLOCK_SIZE=$(blockdev --getsize64 "${FRP_BLOCK}")

if [[ "${FRP_BLOCK_SIZE}" -le 0 ]]; then
    echo "frp block size <= 0"
    exit -1
fi

# Calculate offsets
FRP_OEM_UNLOCK_SIZE=1
FRP_OEM_UNLOCK_OFFSET=$((${FRP_BLOCK_SIZE} - 1))

FRP_CREDENTIAL_RESERVED_SIZE=1000
FRP_CREDENTIAL_RESERVED_OFFSET=$((${FRP_OEM_UNLOCK_OFFSET} - ${FRP_CREDENTIAL_RESERVED_SIZE}))

TEST_MODE_RESERVED_SIZE=10000
TEST_MODE_RESERVED_OFFSET=$((${FRP_CREDENTIAL_RESERVED_OFFSET} - ${TEST_MODE_RESERVED_SIZE}))

FRP_SECRET_SIZE=32
FRP_SECRET_OFFSET=$((${TEST_MODE_RESERVED_OFFSET} - ${FRP_SECRET_SIZE}))

FRP_SECRET_MAGIC_SIZE=8
FRP_SECRET_MAGIC_OFFSET=$((${FRP_SECRET_OFFSET} - ${FRP_SECRET_MAGIC_SIZE}))

# Clear credential storage
dd if=/dev/zero of="${FRP_BLOCK}" \
   seek="${FRP_CREDENTIAL_RESERVED_OFFSET}" \
   count="${FRP_CREDENTIAL_RESERVED_SIZE}" \
   bs=1

# Clear FRP secret
dd if=/dev/zero of="${FRP_BLOCK}" \
   seek="${FRP_SECRET_OFFSET}" \
   count="${FRP_SECRET_SIZE}" \
   bs=1

# Write default FRP secret magic
printf "\xDA\xC2\xFC\xCD\xB9\x1B\x09\x88" | dd of="${FRP_BLOCK}" \
    seek="${FRP_SECRET_MAGIC_OFFSET}" \
    count="${FRP_SECRET_MAGIC_SIZE}" \
    bs=1
