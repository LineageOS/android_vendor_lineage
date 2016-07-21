#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_COPY_FILES_LIST=()
PRODUCT_PACKAGES_LIST=()
PACKAGE_LIST=()
VENDOR_STATE=-1
COMMON=-1

#
# setup_vendor
#
# $1: device name
# $2: vendor name
# $3: CM root directory
# $4: is common device - optional, default to false
# $5: cleanup - optional, default to true
#
# Must be called before any other functions can be used. This
# sets up the internal state for a new vendor configuration.
#
function setup_vendor() {
    local DEVICE="$1"
    if [ -z "$DEVICE" ]; then
        echo "\$DEVICE must be set before including this script!"
        exit 1
    fi

    export VENDOR="$2"
    if [ -z "$VENDOR" ]; then
        echo "\$VENDOR must be set before including this script!"
        exit 1
    fi

    export CM_ROOT="$3"
    if [ ! -d "$CM_ROOT" ]; then
        echo "\$CM_ROOT must be set and valid before including this script!"
        exit 1
    fi

    export OUTDIR=vendor/"$VENDOR"/"$DEVICE"
    if [ ! -d "$CM_ROOT/$OUTDIR" ]; then
        mkdir -p "$CM_ROOT/$OUTDIR"
    fi

    export PRODUCTMK="$CM_ROOT"/"$OUTDIR"/"$DEVICE"-vendor.mk
    export ANDROIDMK="$CM_ROOT"/"$OUTDIR"/Android.mk
    export BOARDMK="$CM_ROOT"/"$OUTDIR"/BoardConfigVendor.mk

    if [ "$4" == "true" ] || [ "$4" == "1" ]; then
        COMMON=1
    else
        COMMON=0
    fi

    if [ "$5" == "true" ] || [ "$5" == "1" ]; then
        VENDOR_STATE=1
    else
        VENDOR_STATE=0
    fi
}

#
# target_file:
#
# $1: colon delimited list
#
# Returns destination filename without args
#
function target_file() {
    local LINE="$1"
    local SPLIT=(${LINE//:/ })
    local COUNT=${#SPLIT[@]}
    if [ "$COUNT" -gt "1" ]; then
        if [[ "${SPLIT[1]}" =~ .*/.* ]]; then
            printf '%s\n' "${SPLIT[1]}"
            return 0
        fi
    fi
    printf '%s\n' "${SPLIT[0]}"
}

#
# target_args:
#
# $1: colon delimited list
#
# Returns optional arguments (last value) for given target
#
function target_args() {
    local LINE="$1"
    local SPLIT=(${LINE//:/ })
    local COUNT=${#SPLIT[@]}
    if [ "$COUNT" -gt "1" ]; then
        if [[ ! "${SPLIT[$COUNT-1]}" =~ .*/.* ]]; then
            printf '%s\n' "${SPLIT[$COUNT-1]}"
        fi
    fi
}

#
# prefix_match:
#
# $1: the prefix to match on
#
# Internal function which loops thru the packages list and returns a new
# list containing the matched files with the prefix stripped away.
#
function prefix_match() {
    local PREFIX="$1"
    for FILE in "${PRODUCT_PACKAGES_LIST[@]}"; do
        if [[ "$FILE" =~ ^"$PREFIX" ]]; then
            printf '%s\n' "${FILE#$PREFIX}"
        fi
    done
}

#
# write_product_copy_files:
#
# Creates the PRODUCT_COPY_FILES section in the product makefile for all
# items in the list which do not start with a dash (-).
#
function write_product_copy_files() {
    local COUNT=${#PRODUCT_COPY_FILES_LIST[@]}
    local TARGET=
    local FILE=
    local LINEEND=

    if [ "$COUNT" -eq "0" ]; then
        return 0
    fi

    printf '%s\n' "PRODUCT_COPY_FILES += \\" >> "$PRODUCTMK"
    for (( i=1; i<COUNT+1; i++ )); do
        FILE="${PRODUCT_COPY_FILES_LIST[$i-1]}"
        LINEEND=" \\"
        if [ "$i" -eq "$COUNT" ]; then
            LINEEND=""
        fi

        TARGET=$(target_file "$FILE")
        printf '    %s/proprietary/%s:system/%s%s\n' \
            "$OUTDIR" "$TARGET" "$TARGET" "$LINEEND" >> "$PRODUCTMK"
    done
    return 0
}

#
# write_packages:
#
# $1: The LOCAL_MODULE_CLASS for the given module list
# $2: "true" if this package is part of the vendor/ path
# $3: "true" if this is a privileged module (only valid for APPS)
# $4: The multilib mode, "32", "64", "both", or "none"
# $5: Name of the array holding the target list
#
# Internal function which writes out the BUILD_PREBUILT stanzas
# for all modules in the list. This is called by write_product_packages
# after the modules are categorized.
#
function write_packages() {

    local CLASS="$1"
    local VENDOR_PKG="$2"
    local PRIVILEGED="$3"
    local MULTILIB="$4"

    # Yes, this is a horrible hack - we create a new array using indirection
    local ARR_NAME="$5[@]"
    local FILELIST=("${!ARR_NAME}")

    local FILE=
    local ARGS=
    local BASENAME=
    local EXTENSION=
    local PKGNAME=
    local SRC=

    for P in "${FILELIST[@]}"; do
        FILE=$(target_file "$P")
        ARGS=$(target_args "$P")

        BASENAME=$(basename "$FILE")
        EXTENSION=${BASENAME##*.}
        PKGNAME=${BASENAME%.*}

        # Add to final package list
        PACKAGE_LIST+=("$PKGNAME")

        SRC="proprietary"
        if [ "$VENDOR_PKG" = "true" ]; then
            SRC+="/vendor"
        fi

        printf 'include $(CLEAR_VARS)\n'
        printf 'LOCAL_MODULE := %s\n' "$PKGNAME"
        printf 'LOCAL_MODULE_OWNER := %s\n' "$VENDOR"
        if [ "$CLASS" = "SHARED_LIBRARIES" ]; then
            if [ "$MULTILIB" = "both" ]; then
                printf 'LOCAL_SRC_FILES_64 := %s/lib64/%s\n' "$SRC" "$FILE"
                printf 'LOCAL_SRC_FILES_32 := %s/lib/%s\n' "$SRC" "$FILE"
                #if [ "$VENDOR_PKG" = "true" ]; then
                #    echo "LOCAL_MODULE_PATH_64 := \$(TARGET_OUT_VENDOR_SHARED_LIBRARIES)"
                #    echo "LOCAL_MODULE_PATH_32 := \$(2ND_TARGET_OUT_VENDOR_SHARED_LIBRARIES)"
                #else
                #    echo "LOCAL_MODULE_PATH_64 := \$(TARGET_OUT_SHARED_LIBRARIES)"
                #    echo "LOCAL_MODULE_PATH_32 := \$(2ND_TARGET_OUT_SHARED_LIBRARIES)"
                #fi
            elif [ "$MULTILIB" = "64" ]; then
                printf 'LOCAL_SRC_FILES := %s/lib64/%s\n' "$SRC" "$FILE"
            else
                printf 'LOCAL_SRC_FILES := %s/lib/%s\n' "$SRC" "$FILE"
            fi
            if [ "$MULTILIB" != "none" ]; then
                printf 'LOCAL_MULTILIB := %s\n' "$MULTILIB"
            fi
        elif [ "$CLASS" = "APPS" ]; then
            if [ -z "$ARGS" ]; then
                if [ "$PRIVILEGED" = "true" ]; then
                    SRC="$SRC/priv-app"
                else
                    SRC="$SRC/app"
                fi
            fi
            printf 'LOCAL_SRC_FILES := %s/%s\n' "$SRC" "$FILE"
            local CERT=platform
            if [ ! -z "$ARGS" ]; then
                CERT="$ARGS"
            fi
            printf 'LOCAL_CERTIFICATE := %s\n' "$CERT"
        elif [ "$CLASS" = "JAVA_LIBRARIES" ]; then
            printf 'LOCAL_SRC_FILES := %s/framework/%s\n' "$SRC" "$FILE"
        elif [ "$CLASS" = "ETC" ]; then
            printf 'LOCAL_SRC_FILES := %s/etc/%s\n' "$SRC" "$FILE"
        elif [ "$CLASS" = "EXECUTABLES" ]; then
            printf 'LOCAL_SRC_FILES := %s/bin/%s\n' "$SRC" "$FILE"
        else
            printf 'LOCAL_SRC_FILES := %s/%s' "$SRC" "$FILE"
        fi
        printf 'LOCAL_MODULE_TAGS := optional\n'
        printf 'LOCAL_MODULE_CLASS := %s\n' "$CLASS"
        printf 'LOCAL_MODULE_SUFFIX := .%s\n' "$EXTENSION"
        if [ "$PRIVILEGED" = "true" ]; then
            printf 'LOCAL_PRIVILEGED_MODULE := true\n'
        fi
        if [ "$VENDOR_PKG" = "true" ]; then
            printf 'LOCAL_PROPRIETARY_MODULE := true\n'
        fi
        printf 'include $(BUILD_PREBUILT)\n\n'
    done
}

#
# write_product_packages:
#
# This function will create BUILD_PREBUILT entries in the
# Android.mk and associated PRODUCT_PACKAGES list in the
# product makefile for all files in the blob list which
# start with a single dash (-) character.
#
function write_product_packages() {
    PACKAGE_LIST=()

    local COUNT=${#PRODUCT_PACKAGES_LIST[@]}

    if [ "$COUNT" = "0" ]; then
        return 0
    fi

    # Figure out what's 32-bit, what's 64-bit, and what's multilib
    # I really should not be doing this in bash due to shitty array passing :(
    local T_LIB32=( $(prefix_match "lib/") )
    local T_LIB64=( $(prefix_match "lib64/") )
    local MULTILIBS=( $(comm -12 <(printf '%s\n' "${T_LIB32[@]}") <(printf '%s\n' "${T_LIB64[@]}")) )
    local LIB32=( $(comm -23 <(printf '%s\n'  "${T_LIB32[@]}") <(printf '%s\n' "${MULTILIBS[@]}")) )
    local LIB64=( $(comm -23 <(printf '%s\n' "${T_LIB64[@]}") <(printf '%s\n' "${MULTILIBS[@]}")) )

    echo "lib64: ${LIB64[@]}"
    if [ "${#MULTILIBS[@]}" -gt "0" ]; then
        write_packages "SHARED_LIBRARIES" "false" "false" "both" "MULTILIBS" >> "$ANDROIDMK"
    fi
    if [ "${#LIB32[@]}" -gt "0" ]; then
        write_packages "SHARED_LIBRARIES" "false" "false" "32" "LIB32" >> "$ANDROIDMK"
    fi
    if [ "${#LIB64[@]}" -gt "0" ]; then
        write_packages "SHARED_LIBRARIES" "false" "false" "64" "LIB64" >> "$ANDROIDMK"
    fi

    local T_V_LIB32=( $(prefix_match "vendor/lib/") )
    local T_V_LIB64=( $(prefix_match "vendor/lib64/") )
    local V_MULTILIBS=( $(comm -12 <(printf '%s\n' "${T_V_LIB32[@]}") <(printf '%s\n' "${T_V_LIB64[@]}")) )
    local V_LIB32=( $(comm -23 <(printf '%s\n' "${T_V_LIB32[@]}") <(printf '%s\n' "${V_MULTILIBS[@]}")) )
    local V_LIB64=( $(comm -23 <(printf '%s\n' "${T_V_LIB64[@]}") <(printf '%s\n' "${V_MULTILIBS[@]}")) )

    if [ "${#V_MULTILIBS[@]}" -gt "0" ]; then
        write_packages "SHARED_LIBRARIES" "true" "false" "both" "V_MULTILIBS" >> "$ANDROIDMK"
    fi
    if [ "${#V_LIB32[@]}" -gt "0" ]; then
        write_packages "SHARED_LIBRARIES" "true" "false" "32" "V_LIB32" >> "$ANDROIDMK"
    fi
    if [ "${#V_LIB64[@]}" -gt "0" ]; then
        write_packages "SHARED_LIBRARIES" "true" "false" "64" "V_LIB64" >> "$ANDROIDMK"
    fi

    # Apps
    local APPS=( $(prefix_match "app/") )
    if [ "${#APPS[@]}" -gt "0" ]; then
        write_packages "APPS" "false" "false" "none" "APPS" >> "$ANDROIDMK"
    fi
    local PRIV_APPS=( $(prefix_match "priv-app/") )
    if [ "${#PRIV_APPS[@]}" -gt "0" ]; then
        write_packages "APPS" "false" "true" "none" "PRIV_APPS" >> "$ANDROIDMK"
    fi
    local V_APPS=( $(prefix_match "vendor/app/") )
    if [ "${#V_APPS[@]}" -gt "0" ]; then
        write_packages "APPS" "true" "false" "none" "V_APPS" >> "$ANDROIDMK"
    fi
    local V_PRIV_APPS=( $(prefix_match "vendor/priv-app/") )
    if [ "${#V_PRIV_APPS[@]}" -gt "0" ]; then
        write_packages "APPS" "true" "true" "none" "V_PRIV_APPS" >> "$ANDROIDMK"
    fi

    # Framework
    local FRAMEWORK=( $(prefix_match "framework/") )
    if [ "${#FRAMEWORK[@]}" -gt "0" ]; then
        write_packages "JAVA_LIBRARIES" "false" "false" "none" "FRAMEWORK" >> "$ANDROIDMK"
    fi

    # Etc
    local ETC=( $(prefix_match "etc/") )
    if [ "${#ETC[@]}" -gt "0" ]; then
        write_packages "ETC" "false" "false" "none" "ETC" >> "$ANDROIDMK"
    fi
    local V_ETC=( $(prefix_match "vendor/etc/") )
    if [ "${#V_ETC[@]}" -gt "0" ]; then
        write_packages "ETC" "true" "false" "none" "V_ETC" >> "$ANDROIDMK"
    fi

    # Executables
    local BIN=( $(prefix_match "bin/") )
    if [ "${#BIN[@]}" -gt "0"  ]; then
        write_packages "EXECUTABLES" "false" "false" "none" "BIN" >> "$ANDROIDMK"
    fi
    local V_BIN=( $(prefix_match "vendor/bin/") )
    if [ "${#V_BIN[@]}" -gt "0" ]; then
        write_packages "EXECUTABLES" "true" "false" "none" "V_BIN" >> "$ANDROIDMK"
    fi

    # Actually write out the final PRODUCT_PACKAGES list
    local PACKAGE_COUNT=${#PACKAGE_LIST[@]}

    if [ "$PACKAGE_COUNT" -eq "0" ]; then
        return 0
    fi

    printf '\n%s\n' "PRODUCT_PACKAGES += \\" >> "$PRODUCTMK"
    for (( i=1; i<PACKAGE_COUNT+1; i++ )); do
        local LINEEND=" \\"
        if [ "$i" -eq "$PACKAGE_COUNT" ]; then
            LINEEND=""
        fi
        printf '    %s%s\n' "${PACKAGE_LIST[$i-1]}" "$LINEEND" >> "$PRODUCTMK"
    done
}

#
# write_header:
#
# $1: file which will be written to
#
# writes out the copyright header with the current year.
# note that this is not an append operation, and should
# be executed first!
#
function write_header() {
    YEAR=$(date +"%Y")

    [ "$COMMON" -eq 1 ] && local DEVICE="$DEVICE_COMMON"

    cat << EOF > $1
# Copyright (C) $YEAR The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is generated by device/$VENDOR/$DEVICE/setup-makefiles.sh

EOF
}

#
# write_headers:
#
# $1: devices falling under common to be added to guard - optional
#
# Calls write_header for each of the makefiles and creates
# the initial path declaration and device guard for the
# Android.mk
#
function write_headers() {
    write_header "$ANDROIDMK"
    cat << EOF >> "$ANDROIDMK"
LOCAL_PATH := \$(call my-dir)

EOF
    if [ "$COMMON" -ne 1 ]; then
        cat << EOF >> "$ANDROIDMK"
ifeq (\$(TARGET_DEVICE),$DEVICE)

EOF
    else
        if [ -z "$1" ]; then
            echo "Argument with devices to be added to guard must be set!"
            exit 1
        fi
        cat << EOF >> "$ANDROIDMK"
ifneq (\$(filter $1,\$(TARGET_DEVICE)),)

EOF
    fi

    write_header "$BOARDMK"
    write_header "$PRODUCTMK"
}

#
# write_footers:
#
# Closes the inital guard and any other finalization tasks. Must
# be called as the final step.
#
function write_footers() {
    cat << EOF >> "$ANDROIDMK"
endif
EOF
}

# Return success if adb is up and not in recovery
function _adb_connected {
    {
        if [[ "$(adb get-state)" == device &&
              "$(adb shell test -e /sbin/recovery; echo $?)" == 0 ]]
        then
            return 0
        fi
    } 2>/dev/null

    return 1
};

#
# parse_file_list
#
function parse_file_list() {
    if [ ! -e "$1" ]; then
        echo "$1 does not exist!"
        exit 1
    fi

    PRODUCT_PACKAGES_LIST=()
    PRODUCT_COPY_FILES_LIST=()

    while read -r line; do
        if [ -z "$line" ]; then continue; fi

        # if line starts with a dash, it needs to be packaged
        if [[ "$line" =~ ^- ]]; then
            PRODUCT_PACKAGES_LIST+=("${line#-}")
        else
            PRODUCT_COPY_FILES_LIST+=("$line")
        fi

    done < <(egrep -v '(^#|^[[:space:]]*$)' "$1" | sort | uniq)
}

#
# write_makefiles:
#
# $1: file containing the list of items to extract
#
# Calls write_product_copy_files and write_product_packages on
# the given file and appends to the Android.mk as well as
# the product makefile.
#
function write_makefiles() {
    if [ ! -e "$1" ]; then
        echo "$1 does not exist!"
        exit 1
    fi
    parse_file_list "$1"
    write_product_copy_files
    write_product_packages
}

#
# init_adb_connection:
#
# Starts adb server and waits for the device
#
function init_adb_connection() {
    adb start-server # Prevent unexpected starting server message from adb get-state in the next line
    if ! _adb_connected; then
        echo "No device is online. Waiting for one..."
        echo "Please connect USB and/or enable USB debugging"
        until _adb_connected; do
            sleep 1
        done
        echo "Device Found."
    fi

    # Retrieve IP and PORT info if we're using a TCP connection
    TCPIPPORT=$(adb devices | egrep '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+[^0-9]+' \
        | head -1 | awk '{print $1}')
    adb root &> /dev/null
    sleep 0.3
    if [ -n "$TCPIPPORT" ]; then
        # adb root just killed our connection
        # so reconnect...
        adb connect "$TCPIPPORT"
    fi
    adb wait-for-device &> /dev/null
    sleep 0.3
}

#
# extract:
#
# $1: file containing the list of items to extract
# $2: path to extracted system folder, or "adb" to extract from device
#
function extract() {
    if [ ! -e "$1" ]; then
        echo "$1 does not exist!"
        exit 1
    fi

    if [ -z "$OUTDIR" ]; then
        echo "Output dir not set!"
        exit 1
    fi

    parse_file_list "$1"

    # Allow failing, so we can try $DEST and/or $FILE
    set +e

    local FILELIST=( ${PRODUCT_COPY_FILES_LIST[@]} ${PRODUCT_PACKAGES_LIST[@]} )
    local COUNT=${#FILELIST[@]}
    local FILE=
    local DEST=
    local SRC="$2"
    local OUTPUT_DIR="$CM_ROOT"/"$OUTDIR"/proprietary
    local DIR=

    if [ "$SRC" = "adb" ]; then
        init_adb_connection
    fi

    if [ "$VENDOR_STATE" -eq "0" ]; then
        echo "Cleaning output directory ($OUTPUT_DIR).."
        rm -rf "${OUTPUT_DIR:?}/"*
        VENDOR_STATE=1
    fi

    echo "Extracting $COUNT files in $1 from $SRC:"

    for (( i=1; i<COUNT+1; i++ )); do
        local SPLIT=(${FILELIST[$i-1]//:/ })
        local FILE="${SPLIT[0]#-}"
        local DEST="${SPLIT[1]}"
        if [ -z "$DEST" ]; then
            DEST="$FILE"
        fi
        if [ "$SRC" = "adb" ]; then
            printf '  - %s .. ' "/system/$FILE"
        else
            printf '  - %s \n' "/system/$FILE"
        fi
        DIR=$(dirname "$DEST")
        if [ ! -d "$OUTPUT_DIR/$DIR" ]; then
            mkdir -p "$OUTPUT_DIR/$DIR"
        fi
        if [ "$SRC" = "adb" ]; then
            # Try CM target first
            adb pull "/system/$DEST" "$OUTPUT_DIR/$DEST"
            # if file does not exist try OEM target
            if [ "$?" != "0" ]; then
                adb pull "/system/$FILE" "$OUTPUT_DIR/$DEST"
            fi
        else
            # Try OEM target first
            cp "$SRC/system/$FILE" "$OUTPUT_DIR/$DEST"
            # if file does not exist try CM target
            if [ "$?" != "0" ]; then
                cp "$SRC/system/$DEST" "$OUTPUT_DIR/$DEST"
            fi
        fi
        chmod 644 "$OUTPUT_DIR/$DEST"
    done

    # Don't allow failing
    set -e
}
