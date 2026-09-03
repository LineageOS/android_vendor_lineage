#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Pick a libclang that the tree's `bindgen` can actually use to generate the
# kernel's Rust bindings.
#
# The kernel wants the libclang matching the Clang it is compiled with, and that
# is what this prints whenever it works. It does not always work though: LLVM
# 22.0.2 and later report records that were forward referenced before they were
# defined (`struct hlist_node` in <linux/types.h>, for instance, is first
# mentioned by `struct hlist_head`) as incomplete. `bindgen` then emits them as
# opaque `pub struct foo { pub _address: u8 }`, dropping every field, and
# rust/kernel fails to build with hundreds of E0560/E0609 errors. Generation
# still exits 0 with no diagnostics, so this has to be probed for.
#
# When the matching libclang is unusable, fall back to the newest usable Clang
# prebuilt in the tree. Newest matters: `bindgen` is handed the kernel's
# KBUILD_CFLAGS together with -Werror=unknown-warning-option, so a libclang
# older than the Clang those flags were probed against fails outright. That
# fallback is a best effort, and it cannot help when every usable libclang is
# older than the Clang the kernel is built with - it only turns a silently
# miscompiled kernel into a build that fails with a clear error.
#
# Usage: select_kernel_libclang.sh <bindgen> <clang dir> [clang prebuilts root]
#
# Prints the matching lib dir if it is usable, otherwise the newest usable
# candidate found under the prebuilts root. If nothing is usable, <clang
# dir>/lib is printed unchanged, so the build keeps today's behaviour and fails
# visibly instead of silently swapping toolchains.

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

# `probe_b` is only forward referenced by `probe_a` before being defined, which
# is the exact shape the broken libclang releases get wrong. Deliberately no
# #include, so the probe does not depend on host headers.
cat > "$tmpdir/probe.h" <<'EOF'
struct probe_a { struct probe_b *p; };
struct probe_b { int x; };
EOF

# Echoes nothing and fails if $1 does not hold a libclang bindgen can use.
probe() {
    local out

    # Match how clang-sys looks libclang up, not just the unversioned soname:
    # upstream releases ship libclang.so.<major>.<minor> and distributions often
    # keep the bare symlink in a separate -dev package.
    compgen -G "$1/libclang.so*" > /dev/null || return 1

    # Mirror the LD_LIBRARY_PATH the kernel build runs with, so an out of tree
    # toolchain that needs its own shared libraries is not misjudged as broken.
    out="$(LIBCLANG_PATH="$1" \
        LD_LIBRARY_PATH="$1:$clang_dir/lib:$clang_dir/lib64:$LD_LIBRARY_PATH" \
        "$bindgen" "$tmpdir/probe.h" \
        --use-core --no-layout-tests --no-doc-comments -- -x c 2>/dev/null)" || return 1

    # A working libclang gives `probe_b` its `x` field, a broken one collapses it
    # to bindgen's opaque `_address` placeholder.
    case "$out" in
        *"struct probe_b"*"_address"*) return 1 ;;
        *"struct probe_b"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Out of tree toolchains are not required to use the AOSP lib/ layout.
tried=""
for dir in "$clang_dir/lib" "$clang_dir/lib64"; do
    tried="$tried $dir"
    probe "$dir" && { echo "$dir"; exit 0; }
done

[ -d "$clang_root" ] || fallback

# Reading AndroidVersion.txt keeps the candidate scan free for the in tree
# prebuilts, out of tree toolchains have to be asked.
clang_version() {
    if [ -r "$1/AndroidVersion.txt" ]; then
        sed -nE '1s:^([0-9]+(\.[0-9]+)*).*:\1:p' "$1/AndroidVersion.txt"
    elif [ -x "$1/bin/clang" ]; then
        "$1/bin/clang" --version 2>/dev/null |
            sed -nE '1s:.*clang version ([0-9]+(\.[0-9]+)*).*:\1:p'
    fi
}

# The Clang the kernel is compiled with, if we can tell.
kernel_clang_version="$(clang_version "$clang_dir")"
kernel_clang_major="${kernel_clang_version%%.*}"

# Rank same major version first: those only differ by patch releases, so their
# record layouts match the compiler's and the bindings stay ABI correct. Then
# newest first, because bindgen is handed the kernel's KBUILD_CFLAGS along with
# -Werror=unknown-warning-option and an older libclang rejects newer flags.
#
# Several prebuilts report the same `clang --version` (clang-r563880, -r563880c
# and -r574158 are all "21.0.0"), so break the tie on the toolchain revision in
# the directory name, then on the name itself to order suffixed respins.
for candidate in $(
    for dir in "$clang_root"/clang-*/; do
        version="$(clang_version "${dir%/}")"
        [ -n "$version" ] || continue
        name="$(basename "${dir%/}")"
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
