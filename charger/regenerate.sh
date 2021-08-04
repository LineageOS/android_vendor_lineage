#!/bin/bash

if [ -z "$(which convert)" ] || [ -z "$(which pngcrush)" ]; then
    echo "Please install imagemagick and pngcrush"
    exit 1
fi

for DENSITY in mdpi:160 hdpi:240 xhdpi:320 xxhdpi:480 xxxhdpi:640; do
    DPI=$(echo $DENSITY | cut -f1 -d ':')
    WIDTH=$(echo $DENSITY | cut -f2 -d ':')

    rm -rf $DPI
    mkdir $DPI

    for SVG in svg/*.svg; do
        PNG="$DPI/$(basename $SVG | cut -f1 -d '.').png"
        convert -density $WIDTH -resize ${WIDTH}x${WIDTH} $SVG $PNG
    done

    SCALEFILE="$DPI/battery_scale.png"
    SCALEFILES="$(ls $DPI/battery_scale_*.png)"
    FRAMES="$(ls -l $SCALEFILES | wc -l)"
    SCALEHEIGHT=$(($WIDTH * $FRAMES))

    convert -size ${WIDTH}x${SCALEHEIGHT} canvas:black $SCALEFILES -fx "u[j%$FRAMES+1].p{i,int(j/$FRAMES)}" png24:$SCALEFILE.tmp
    pngcrush -text b "Frames" "$FRAMES" $SCALEFILE.tmp $SCALEFILE
    rm $SCALEFILES $SCALEFILE.tmp
done
