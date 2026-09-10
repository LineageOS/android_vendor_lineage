#!/bin/sh
#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# The kernel's CC when RBE is enabled, see BoardConfigKernel.mk.
#
# reclient only understands an actual compilation, so everything else kbuild
# runs the compiler for is executed directly, and the -Wp,-MD dependency file
# has to be declared by hand since reclient doesn't derive it as an output.

compile=
depfile=
prev=
src=

for arg in "$@"; do
    if [ "$prev" = "-MF" ]; then
        depfile=$arg
        prev=
        continue
    fi
    case $arg in
        -c) compile=true ;;
        -E | -S | -M | -MM) compile=; break ;;
        -MF) prev=$arg ;;
        -Wp,-MD,* | -Wp,-MMD,*) depfile=${arg##*,} ;;
        -*) ;;
        *.c | *.S | *.s) src=$arg ;;
    esac
done

if [ -z "$KERNEL_RBE_WRAPPER" ] || [ -z "$compile" ] || [ ! -f "$src" ]; then
    exec "$@"
fi

# reproxy runs the command with an environment of its own
cc=$1
shift
case $cc in
    */*) ;;
    *) cc=$(command -v "$cc") || exit 1 ;;
esac

if [ -z "$depfile" ]; then
    exec $KERNEL_RBE_WRAPPER "$cc" "$@"
fi

# reclient wants output paths relative to the exec root
case $depfile in
    /*)
        output=${depfile#"$RBE_exec_root"/}
        ;;
    *)
        workdir=${PWD#"$RBE_exec_root"}
        workdir=${workdir#/}
        output=${workdir:+$workdir/}$depfile
        ;;
esac

exec $KERNEL_RBE_WRAPPER "--output_files=$output" "$cc" "$@"
