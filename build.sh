#!/bin/bash

KERNEL_DEFCONFIG=envoy_defconfig

export HOME=/home/$USER
export CLANG_PATH=$HOME/proton-clang/bin
export PATH="$CLANG_PATH:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=$(pwd)/tools/dtc
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_BUILD_USER=Envoy
export KBUILD_BUILD_HOST=EK2

# Show compilation time
START=$(date +"%s")

echo
echo "[*]Kernel is using the current defconfig: $KERNEL_DEFCONFIG"
echo
make CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out $KERNEL_DEFCONFIG -j$(nproc --all)

echo
echo "[*]Begin compilation..."
echo
make CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out -j$(nproc --all)

echo
echo "[*]Verifying Image.gz.dtb and dtbo.img"
echo
ls $PWD/out/arch/arm64/boot/Image.gz-dtb
ls $PWD/out/arch/arm64/boot/dtbo.img

END=$(date +"%s")
DIFF=$((END - START))
echo
echo "[*]Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
echo