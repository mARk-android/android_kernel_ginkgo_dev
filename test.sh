#!/bin/bash

MOXES_KERNEL_NAME="MoxesKernel_"
MOXES_KERNEL_VERSION="v1.1"
ARASAKA_BUILD_DATE="_$(date +%d.%m.%y-%H:%M)"

IMGNAME=$MOXES_KERNEL_NAME$MOXES_KERNEL_VERSION$ARASAKA_BUILD_DATE

mkbootimg=~/tools/mkbootimg/mkbootimg.py
ramdisk=~/tools/samsung/ramdisk.cpio.empty

echo
echo "Building Kernel Image"
echo
$mkbootimg \
    --kernel out/arch/arm64/boot/Image.gz-dtb \
    --ramdisk $ramdisk \
    --cmdline 'console=null androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=1 androidboot.usbcontroller=a600000.dwc3 firmware_class.path=/vendor/firmware_mnt/image nokaslr printk.devkmsg=on'\
    --base           0x00000000 \
    --board          SRPRL06C005 \
    --pagesize       4096 \
    --kernel_offset  0x00008000 \
    --ramdisk_offset 0x00000000 \
    --second_offset  0x00000000 \
    --tags_offset    0x01e00000 \
    --os_version     '11.0.0' \
    --os_patch_level '2021-03' \
    --header_version 1 \
    -o $IMGNAME.img

ls -al $IMGNAME.img