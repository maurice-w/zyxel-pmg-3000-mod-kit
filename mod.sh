#!/bin/bash

FIRMWARE_IN=$1
FIRMWARE_OUT="./fmk/new-firmware.bin"
FMK_DIR="../firmware-mod-kit"
FMK_EXTRACT="${FMK_DIR}/extract-firmware.sh"
FMK_BUILD="${FMK_DIR}/build-firmware.sh"
CRC32="${FMK_DIR}/src/crcalc/crc32"

BUILD_TIME=`date '+%Y-%m-%d %H:%M:%S'`

function byte_hex2bin {
    v=$1
    if [ $2 -eq 1 ]; then
	echo "\x${v:6:2}\x${v:4:2}\x${v:2:2}\x${v:0:2}"
    else
	echo "\x${v:0:2}\x${v:2:2}\x${v:4:2}\x${v:6:2}"
    fi
}

function firmware_patch_img {
    # convert squashfs filesystem creation date string to binary and write to bootloader
    stime=`binwalk $FIRMWARE_OUT | grep 0x140200 | grep -oP "created\: ([0-9\-\: ]+)" | sed -e "s/created: //g"`
    itime=`date --date="${stime}" +"%s"`
    itime=$(($itime + 7202))
    htime=`echo "obase=16; ${itime}" | bc`
    htime=$(byte_hex2bin $htime 1)
    echo -e "${htime}" | dd of=$FIRMWARE_OUT bs=1 seek=520 count=4 conv=notrunc
}

function firmware_crc {
    dd if=/dev/zero of=$FIRMWARE_OUT bs=1 seek=$1 count=4 conv=notrunc
    crc=`$CRC32 $FIRMWARE_OUT $3 $4 | tail -n 1 | awk '{print $2}' | sed "s/0x//1"`
    crc=$(byte_hex2bin $crc $2)
    echo -e "${crc}" | dd of=$FIRMWARE_OUT bs=1 seek=$1 count=4 conv=notrunc
}

$FMK_EXTRACT $FIRMWARE_IN
# add / modify files in rootfs here
$FMK_BUILD

firmware_patch_img

firmware_crc 540 1 1024 3735040 # file without header and bootloader
firmware_crc 544 1 512  512     # bootloader only
firmware_crc 104 0 0    3736064 # entire file
