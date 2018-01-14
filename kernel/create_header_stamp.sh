#/bin/bash

KERNEL_SRC=$1
KERNEL_ARCH=$2
STAMP_FILE=$3

cd $KERNEL_SRC
if grep -q '^version_h' 'Makefile'; then
	depdirs="arch/$KERNEL_ARCH/include/uapi include/uapi"
else
	depdirs="arch/$KERNEL_ARCH/include/asm include"
fi
deps="Makefile $(find $depdirs -type f -name '*.h')"
for f in $deps; do
	echo "  $KERNEL_SRC/$$f \\" >> $STAMP_FILE
done
echo "" >> $STAMP_FILE
for f in $deps; do
	echo "$KERNEL_SRC/$f:" >> $STAMP_FILE
	echo "" >> $STAMP_FILE
done
