#!/bin/sh

TARGET=dmenu.bin

# Copy boot assets from central location
ASSETS=../../skeleton/SYSTEM/res
cp $ASSETS/installing@2x.bmp installing.bmp
cp $ASSETS/updating@2x.bmp updating.bmp
cp $ASSETS/bootlogo@2x.png boot_logo.png

mkdir -p output
# Skip standard 54-byte BMP header (now using 24-bit BMPs)
if [ ! -f output/installing ]; then
	dd skip=54 iflag=skip_bytes if=installing.bmp of=output/installing
fi
if [ ! -f output/updating ]; then
	dd skip=54 iflag=skip_bytes if=updating.bmp of=output/updating
fi

convert boot_logo.png -type truecolor output/boot_logo.bmp && gzip -f -n output/boot_logo.bmp

cd output
if [ ! -f data ]; then
	# tar -czvf data installing updating
	zip -r data.zip installing updating
	mv data.zip data
fi

cp ~/buildroot/output/images/rootfs.ext2 ./

cat ../boot.sh > $TARGET
echo BINARY >> $TARGET
uuencode data data >> $TARGET