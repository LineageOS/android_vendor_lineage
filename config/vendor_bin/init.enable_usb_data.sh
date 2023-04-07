#!/vendor/bin/sh
# Helper script for enabling USB data based on the current type-C role,
# or for enabling or disabling USB data unconditionally.

set -euo pipefail

syntax() {
    echo "Syntax: $0 <usb-data-enabled-path> <value> [type-c-data-partner-path] [type-c-data-role-path] [find-for-host] ([other-path-to-change] [value-for-host-role] [value-for-other])..."
    echo
    echo "For example: $0 usb_data_enabled 1 partner role [host] mode host peripheral"
    echo "This first writes the value '1' is to the file 'usb_data_enabled' regardless of the role or whether a device is connected."
    echo "Then, we check to see if the path 'partner' exists, and if not, stop processing and exit, assuming that there is no USB device connected."
    echo "Next, we check the file 'role' for the contents '[host]', in which case the device is considered to be in USB host mode."
    echo "Finally, the file 'mode' has the value 'host' written to it if in USB host mode, or 'peripheral' if not."
    echo "The arguments can be expanded to modify as many files as necessary."
}

main() {
    logd "starting"

    case "$*" in
        --help|-h|"")
            syntax
            return 0
        ;;
    esac

    if [ $# -lt 2 ]; then
        loge "Missing usb data enabled path and/or value."
        return $err
    fi

    local data_enabled_path="$1"
    local data_enabled_value="$2"

    # Enable or disable USB data.
    write "$data_enabled_path" "$data_enabled_value"
    local err=$?

    if [ $# -eq 2 ]; then
        # We only needed to write a value; can exit now.
        return $err
    fi

    if [ $# -lt 5 ]; then
        loge "Missing arguments (got $#, expected 5+)"
        return 1
    fi

    # Stop if no device connected. Wait a bit to be sure. (Necessary in early boot...)
    local partner_path="$3"
    local tries=25
    local sleep_per_try=0.2
    local usb_connected=
    while [ "$tries" -gt 0 ]; do
        if [ -e "$partner_path" ]; then
            usb_connected=1
            break
        fi
        sleep "$sleep_per_try"
        tries=$((tries-1))
    done
    if [ ! -n "$usb_connected" ]; then
        logd "no device connected; exiting"
        return 0
    fi

    # Read current USB Type-C data role; determine if it is a host role.
    local data_role_path="$4"
    local data_role_find_for_host="$5"
    shift 5

    local data_role_value=
    if ! data_role_value="$(cat "$data_role_path")"; then
        loge "failed to read from data role path '$data_role_path'"
        return 1
    fi
    local is_host_role=
    if printf "%s\n" "$data_role_value" | grep -Fq "$data_role_find_for_host"; then
        is_host_role=1
    fi

    # Modify all provided files according to whether or not we are in the host data role.
    # syntax: path host_value device_value
    while [ "$#" -ge 3 ]; do
        local path="$1"
        local value
        if [ -n "$is_host_role" ]; then
            value="$2"
        else
            value="$3"
        fi
        write "$path" "$value" || true # do not stop on failure
        shift 3
    done
}

write() {
    local path="$1"
    local value="$2"

    if printf "%s" "$value" > "$path"; then
        logd "wrote '$value' to '$path'"
    else
        loge "failed to write '$value' to '$path'"
        return 1
    fi
}

logd() {
    log -p d "enable_usb_data: $*" || true # do not stop on log failure
}
loge() {
    log -p e "enable_usb_data: $*" || true # do not stop on log failure
}

main "$@"
