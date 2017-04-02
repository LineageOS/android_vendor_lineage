#!/bin/bash

WIDTH="$1"
HEIGHT="$2"
HALF_RES="$3"
OUT="$ANDROID_PRODUCT_OUT/obj/BOOTANIMATION"

if [ "$HEIGHT" -lt "$WIDTH" ]; then
    IMAGEWIDTH="$HEIGHT"
else
    IMAGEWIDTH="$WIDTH"
fi

RESOLUTION=""$WIDTH"x"$HEIGHT""

mkdir -p $ANDROID_PRODUCT_OUT/obj/BOOTANIMATION/bootanimation/part0
tar xfp "vendor/cm/bootanimation/bootanimation.tar" -C "$OUT/bootanimation/"
mogrify -resize $RESOLUTION -colors 250 -background white -gravity center -extent $RESOLUTION "$OUT/bootanimation/"*"/"*".png"

# Create desc.txt
echo "$WIDTH $HEIGHT" 60 > "$OUT/bootanimation/desc.txt"
cat "vendor/cm/bootanimation/desc.txt" >> "$OUT/bootanimation/desc.txt"

# Create bootanimation.zip
cd "$OUT/bootanimation"

zip -qr0 "$OUT/bootanimation.zip" .
