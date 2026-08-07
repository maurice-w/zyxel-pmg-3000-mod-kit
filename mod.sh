#!/bin/bash

# FIRMWARE_IN needs to be a .upf file (with header), not a raw mtd2 / mtd3 image
FIRMWARE_IN=$1
# FIRMWARE_SSH_IN needs to be a an older firmware with SSH
FIRMWARE_SSH_IN=$2
FIRMWARE_OUT="firmware_with_ssh.upf"
FMK_DIR="/opt/firmware-mod-kit/trunk"
FMK_EXTRACT="${FMK_DIR}/extract-firmware.sh"
FMK_BUILD="${FMK_DIR}/build-firmware.sh"
CRC32="${FMK_DIR}/src/crcalc/crc32"

function byte_hex2bin {
    v=$1
    if [ $2 -eq 1 ]; then
        echo "\x${v:6:2}\x${v:4:2}\x${v:2:2}\x${v:0:2}"
    else
        echo "\x${v:0:2}\x${v:2:2}\x${v:4:2}\x${v:6:2}"
    fi
}

function firmware_crc {
    dd if=/dev/zero of=$FIRMWARE_OUT bs=1 seek=$1 count=4 conv=notrunc
    crc=`$CRC32 $FIRMWARE_OUT $3 $4 | tail -n 1 | awk '{print $2}' | sed "s/0x//1"`
    crc=$(byte_hex2bin $crc $2)
    echo -e "${crc}" | dd of=$FIRMWARE_OUT bs=1 seek=$1 count=4 conv=notrunc
}

rm -r fmk
rm -r dropbear

$FMK_EXTRACT $FIRMWARE_SSH_IN
cp -a fmk/rootfs/etc/dropbear ./
rm -r fmk

$FMK_EXTRACT $FIRMWARE_IN
cp -a fmk/rootfs/usr/sbin/dropbear fmk/rootfs/usr/local/bin/
cp -a dropbear fmk/rootfs/etc/
$FMK_BUILD
mv fmk/new-firmware.bin $FIRMWARE_OUT

firmware_crc 540 1 1024 3669504 # checksum of the first 3,669,504 bytes of the image without bootloader and header, written to bootloader
firmware_crc 544 1 512  512     # checksum of bootloader only, written to bootloader
firmware_crc 104 0 0    3736064 # checksum of image with bootloader and header, written to header
