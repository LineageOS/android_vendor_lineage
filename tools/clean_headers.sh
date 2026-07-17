#!/bin/bash
set -eu

export ANDROID_BUILD_TOP="$PWD"

rm -rf "$1/usr/include/asm" "$1/usr/include/asm-generic"

./bionic/libc/kernel/tools/clean_header.py -u \
    "$1/usr/include/linux/eventpoll.h"
