#!/bin/bash
set -eu

export ANDROID_BUILD_TOP="$PWD"

./bionic/libc/kernel/tools/clean_header.py -u \
    "$1/usr/include/asm/signal.h" \
    "$1/usr/include/asm-generic/signal.h" \
    "$1/usr/include/linux/eventpoll.h"

# Older kernels (5.10) still define struct sched_param in the uapi, while
# bionic's <sched.h> now includes <linux/sched/types.h> and defines it itself.
if [ -f "$1/usr/include/linux/sched/types.h" ]; then
    sed -i '/^struct sched_param {/,/^};/d' "$1/usr/include/linux/sched/types.h"
fi

# arm64 asm/sigcontext.h is also seen by 32-bit vendor code, which has no
# __uint128_t; keep the same 512-byte layout there.
if [ -f "$1/usr/include/asm/sigcontext.h" ]; then
    sed -i 's/^\(\s*\)__uint128_t vregs\[32\];/#ifdef __aarch64__\n\1__uint128_t vregs[32];\n#else\n\1__u64 vregs[64];\n#endif/' "$1/usr/include/asm/sigcontext.h"
fi
