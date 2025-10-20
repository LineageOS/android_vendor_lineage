#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys
import tarfile
import subprocess
from pathlib import Path

PARAM_OUT = sys.argv[1]
PARAM_GENDIR = sys.argv[2]
PARAM_BOOTANIMATION_TAR = sys.argv[3]
PARAM_DESC_TXT = sys.argv[4]
PARAM_MOGRIFY = sys.argv[5]
PARAM_SOONG_ZIP = sys.argv[6]
PARAM_TARGET_SCREEN_HEIGHT = int(sys.argv[7])
PARAM_TARGET_SCREEN_WIDTH = int(sys.argv[8])
PARAM_TARGET_BOOTANIMATION_HALF_RES = sys.argv[9].lower() == "true"

INTERMEDIATES = Path(PARAM_GENDIR) / "intermediates"
INTERMEDIATES.mkdir(parents=True, exist_ok=True)

with tarfile.open(PARAM_BOOTANIMATION_TAR, "r:*") as tar:
    tar.extractall(path=INTERMEDIATES)

IMAGEWIDTH = min(PARAM_TARGET_SCREEN_HEIGHT, PARAM_TARGET_SCREEN_WIDTH)
IMAGESCALEWIDTH = IMAGEWIDTH
IMAGESCALEHEIGHT = IMAGESCALEWIDTH // 3

if PARAM_TARGET_BOOTANIMATION_HALF_RES:
    IMAGEWIDTH //= 2

IMAGEHEIGHT = IMAGEWIDTH // 3
RESOLUTION = f"{IMAGEWIDTH}x{IMAGEHEIGHT}"

subprocess.run(
    [PARAM_MOGRIFY, "-resize", RESOLUTION, "-colors", "256", *map(str, INTERMEDIATES.glob("*/*.png"))],
    check=True
)

desc_path = INTERMEDIATES / "desc.txt"
with open(desc_path, "w") as f:
    f.write(f"{IMAGESCALEWIDTH} {IMAGESCALEHEIGHT} 60\n")
    with open(PARAM_DESC_TXT, "r") as desc_in:
        f.write(desc_in.read())

subprocess.run(
    [PARAM_SOONG_ZIP, "-L", "0", "-o", PARAM_OUT, "-C", str(INTERMEDIATES), "-D", str(INTERMEDIATES)],
    check=True
)
