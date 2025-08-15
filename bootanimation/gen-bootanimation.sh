#!/bin/bash -e
#
# Copyright (C) 2016 The CyanogenMod Project
#               2017-2024 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PARAM_OUT=$1
PARAM_GENDIR=$2
PARAM_BOOTANIMATION_TAR=$3
PARAM_DESC_TXT=$4
PARAM_MOGRIFY=$5
PARAM_SOONG_ZIP=$6
PARAM_TARGET_SCREEN_HEIGHT=$7
PARAM_TARGET_SCREEN_WIDTH=$8
PARAM_TARGET_BOOTANIMATION_HALF_RES=$9

INTERMEDIATES=$PARAM_GENDIR/intermediates

mkdir -p $INTERMEDIATES

tar xfp $PARAM_BOOTANIMATION_TAR -C $INTERMEDIATES

if [ $PARAM_TARGET_SCREEN_HEIGHT -lt $PARAM_TARGET_SCREEN_WIDTH ]; then
    IMAGEWIDTH=$PARAM_TARGET_SCREEN_HEIGHT
else
    IMAGEWIDTH=$PARAM_TARGET_SCREEN_WIDTH
fi

IMAGESCALEWIDTH=$IMAGEWIDTH
IMAGESCALEHEIGHT=$(expr $IMAGESCALEWIDTH / 3);

if [ "$PARAM_TARGET_BOOTANIMATION_HALF_RES" = "true" ]; then
    IMAGEWIDTH="$(expr "$IMAGEWIDTH" / 2)"
fi

IMAGEHEIGHT=$(expr $IMAGEWIDTH / 3);
RESOLUTION="$IMAGEWIDTH"x"$IMAGEHEIGHT";

$PARAM_MOGRIFY -resize $RESOLUTION -colors 256 $INTERMEDIATES/*/*.png;

echo "$IMAGESCALEWIDTH $IMAGESCALEHEIGHT 60" > $INTERMEDIATES/desc.txt;
cat $PARAM_DESC_TXT >> $INTERMEDIATES/desc.txt

$PARAM_SOONG_ZIP -L 0 -o $PARAM_OUT -C $INTERMEDIATES -D $INTERMEDIATES
