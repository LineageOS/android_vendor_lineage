#!/bin/bash
set -eu

# Rename sigaction struct to __kernel_sigaction just like in bionic/libc/kernel/tools/defaults.py
sed -i "s/struct sigaction /struct __kernel_sigaction /" "$1/usr/include/asm-generic/signal.h"
