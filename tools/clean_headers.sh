#!/bin/bash
set -eu

# Rename sigaction struct to __kernel_sigaction just like in bionic/libc/kernel/tools/defaults.py
find "$1" -name signal.h -exec sed -i "s/struct sigaction /struct __kernel_sigaction /g" {} \;
