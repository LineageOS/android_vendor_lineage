#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Usage: select_kernel_libclang.sh <bindgen> <clang dir> [clang prebuilts root]
#
# LLVM 22.0.2 can silently emit opaque bindgen records for types that were
# forward declared before their definition. Prefer the matching libclang, then
# fall back to the newest candidate that preserves the probed record fields.

bindgen="$1"
clang_dir="$2"
clang_root="$3"

fallback() {
    echo "$clang_dir/lib"
    exit 0
}

[ -x "$bindgen" ] && [ -n "$clang_dir" ] || fallback

tmpdir="$(mktemp -d)" || fallback
trap 'rm -rf "$tmpdir"' EXIT

# Keep the forward declaration pattern that triggers the libclang regression.
# Omitting includes makes the probe independent of host headers.
cat > "$tmpdir/probe.h" <<'EOF'
struct probe_a { struct probe_b *p; };
struct probe_b { int x; };
EOF

probe() {
    local out

    # clang-sys also accepts versioned sonames without a libclang.so symlink.
    compgen -G "$1/libclang.so*" > /dev/null || return 1

    # Avoid bindgen subprocesses that violate the build PATH sandbox.
    out="$(LIBCLANG_PATH="$1" \
        LD_LIBRARY_PATH="$1:$clang_dir/lib:$clang_dir/lib64:$LD_LIBRARY_PATH" \
        "$bindgen" "$tmpdir/probe.h" \
        --use-core --no-layout-tests --no-doc-comments \
        --formatter=none --no-include-path-detection \
        --allowlist-type probe_b -- -x c 2>/dev/null)" || return 1

    case "$out" in
        *"struct probe_b"*"_address"*) return 1 ;;
        *"struct probe_b"*) return 0 ;;
        *) return 1 ;;
    esac
}

tried=""
for dir in "$clang_dir/lib" "$clang_dir/lib64"; do
    tried="$tried $dir"
    probe "$dir" && { echo "$dir"; exit 0; }
done

[ -d "$clang_root" ] || fallback

clang_version() {
    if [ -r "$1/AndroidVersion.txt" ]; then
        sed -nE '1s:^([0-9]+(\.[0-9]+)*).*:\1:p' "$1/AndroidVersion.txt"
    elif [ -x "$1/bin/clang" ]; then
        "$1/bin/clang" --version 2>/dev/null |
            sed -nE '1s:.*clang version ([0-9]+(\.[0-9]+)*).*:\1:p'
    fi
}

kernel_clang_version="$(clang_version "$clang_dir")"
kernel_clang_major="${kernel_clang_version%%.*}"

# Prefer the compiler's major version for ABI compatibility, then newer
# versions because older libclang releases may reject current KBUILD_CFLAGS.
# Toolchain revisions disambiguate prebuilts reporting the same LLVM version.
for candidate in $(
    for dir in "$clang_root"/clang-*/; do
        version="$(clang_version "${dir%/}")"
        [ -n "$version" ] || continue
        name="${dir%/}"
        name="${name##*/}"
        revision="${name#clang-}"
        revision="${revision#r}"
        revision="${revision%%[!0-9]*}"
        rank=1
        [ -n "$kernel_clang_major" ] && [ "${version%%.*}" = "$kernel_clang_major" ] && rank=0
        echo "$rank $version ${revision:-0} $name ${dir%/}/lib"
    done | sort -k1,1n -k2,2rV -k3,3rn -k4,4r | cut -d' ' -f5
); do
    case " $tried " in *" $candidate "*) continue ;; esac
    probe "$candidate" || continue

    candidate_version="$(clang_version "${candidate%/lib}")"
    echo "warning: libclang in $clang_dir is unusable by $bindgen," \
         "generating the kernel Rust bindings with $candidate instead" >&2
    if [ -n "$kernel_clang_major" ] &&
       [ "${candidate_version%%.*}" != "$kernel_clang_major" ]; then
        echo "warning: that libclang is Clang ${candidate_version:-?} while the kernel is" \
             "built with Clang $kernel_clang_version, so the build is expected to fail." \
             "Use a Clang whose libclang works, or set TARGET_KERNEL_LIBCLANG_PATH" >&2
    fi
    echo "$candidate"
    exit 0
done

fallback
