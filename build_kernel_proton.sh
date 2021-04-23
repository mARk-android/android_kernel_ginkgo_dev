#!/bin/bash

KERNEL_DEFCONFIG=moxes_defconfig

export HOME=/home/takemura
export CLANG_PATH=$HOME/proton-clang/bin
export PATH="$CLANG_PATH:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11.0.0
export DTC_EXT=$(pwd)/tools/dtc
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_BUILD_USER=Rogue
export KBUILD_BUILD_HOST=TheMoxes

mkdir out

# Show compilation time
START=$(date +"%s")

echo
echo " Kernel defconfig is set to $KERNEL_DEFCONFIG"
echo
echo " Setting defconfig"
echo
make O=out ARCH=arm64 CC=clang $KERNEL_DEFCONFIG -j$(nproc --all)

echo
echo " Compiling"
echo
make O=out ARCH=arm64 CC=clang -j$(nproc --all)


echo
echo " Verify Image.gz.dtb"
echo
ls $PWD/out/arch/arm64/boot/Image.gz-dtb
ls $PWD/out/arch/arm64/boot/dtbo.img

END=$(date +"%s")
DIFF=$((END - START))
echo
echo -e " Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
echo