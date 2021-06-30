#!/bin/bash
#
# Shell script to build kernel with mARk-clang-13
# git clone https://github.com/mARk-android/toolchain_mARkclang.git
# Specify colors utilized in the terminal
    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    ylw=$(tput setaf 3)             #  yellow
    blu=$(tput setaf 4)             #  blue
    ppl=$(tput setaf 5)             #  purple
    cya=$(tput setaf 6)             #  cyan
    txtbld=$(tput bold)             #  Bold
    bldred=${txtbld}$(tput setaf 1) #  red
    bldgrn=${txtbld}$(tput setaf 2) #  green
    bldylw=${txtbld}$(tput setaf 3) #  yellow
    bldblu=${txtbld}$(tput setaf 4) #  blue
    bldppl=${txtbld}$(tput setaf 5) #  purple
    bldcya=${txtbld}$(tput setaf 6) #  cyan
    txtrst=$(tput sgr0)             #  Reset
    rev=$(tput rev)                 #  Reverse color
    pplrev=${rev}$(tput setaf 5)
    cyarev=${rev}$(tput setaf 6)
    ylwrev=${rev}$(tput setaf 3)
    blurev=${rev}$(tput setaf 4)
    blink=$(tput blink)
    dim=$(tput dim)
    clear=$(tput clear)

# clone mARk-clang
if ! [ -d "$HOME/toolchain/mARk-clang13" ]; then
    git clone https://github.com/mARk-android/toolchain_mARkclang.git $HOME/toolchain/mARk-clang13
else
    echo "${bold}mARk clang 13 is already!mARk clang 13 is alreay${normal}"
fi


# Extra var
    now=$(date +%Y%m%d-%H%M)
    echo build_vers >> build_vers
    export HASH=$( shuf -er -n28   {a..z} {0..9} | paste -sd "")
    export LICZNIK=$( cat -n build_vers | tail -1 | awk '{print $1}')
    VERSION=4.14.238-${LICZNIK}




# Line added to changelog    
    sed  -i "1i\ "                                       AnyKernel3/changelog
    sed  -i "1i\hash: ${HASH}"                           AnyKernel3/changelog
    sed  -i '1i\=======================================' AnyKernel3/changelog
    sed  -i "1i\Date: ${now}          ~~~~~~ ^"          AnyKernel3/changelog
    sed  -i '1i\mARkOS kernel Q MIUI build-'${VERSION}   AnyKernel3/changelog
    sed  -i '1i\=======================================' AnyKernel3/changelog
    
    cp AnyKernel3/changelog changelog.txt   

# Bash HEADER   
    echo -e "\n"
    echo -e ${txtbld}"\n  Starting compiling $VERSION\n"${txtrst};
    echo -e '  commit: '${HASH};
    echo -e ' \n ';




# ENV
CONFIG=vendor/ginkgo-perf_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
KERN_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"

export KBUILD_BUILD_USER="mARk"
export KBUILD_BUILD_HOST="linux"
export PATH="$HOME/toolchain/mARk-clang13/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/toolchain/mARk-clang13/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$($HOME/toolchain/mARk-clang13/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export out=out

# Functions          ™       ™
start_build () {
    make -j$(nproc --all) O=$out \
                          ARCH=arm64 \
                          CC="ccache clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
			  LD="ld.lld" \
			  AS="llvm-as" \
			  OBJCOPY="llvm-objcopy" \
			  OBJDUMP="llvm-objdump" \
			  STRIP="llvm-strip" \
                          CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=aarch64-linux-gnu- \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                          
}

# Build kernel 16.05.2021 02:33:01 Image.gz-dtb dtbo.img
    make O=$out ARCH=arm64 $CONFIG > /dev/null
    
    echo -e ' \n ';
    echo -e ${bldcya}'  ========================================='${txtrst};
    echo -e ${bldcya}'  == '${cya}'Compiling with '${txtrst}${bldylw}${blink}"$KBUILD_COMPILER_STRING" ${txtrst}${bldcya}'=='${txtrst};
    echo -e ${bldcya}'  ========================================='${txtrst};
    echo -e ' \n ';    
    echo -e ${dim}"\n"
    start_build
    echo -e "\n"${txtrst};
    
if [ -f "$out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "$out/arch/arm64/boot/dtbo.img" ]; then
	    echo -e ${bldcya}"\nKernel compiled succesfully! \n    Zipping and packing modules... \n"${txtrst};
	    ZIPNAME="boot•mARkOS•$VERSION•MiuiQ•A10•HMNote8•8T-$(date '+%Y%m%d-%H%M').zip"    
    if [ ! -d AnyKernel3 ]; then
	    git clone -q https://github.com/mARk-android/AnyKernel3.git
    fi;
    
    mv -f $out/arch/arm64/boot/Image.gz-dtb AnyKernel3
    mv -f $out/arch/arm64/boot/dtbo.img AnyKernel3
    mv -f $out/modules.builtin AnyKernel3
    mv -f $out/modules.order AnyKernel3
    
    echo -e ${grn}${txtbld}"\n" 
    find  -type f -name "*.ko" -exec cp {} AnyKernel3/modules/vendor/lib/modules/ \; -print
    echo -e "\n"${txtrst};
  
 
    cd AnyKernel3
	if [ ! -d $KERNEL_DIR/_BUILD_KERNEL ]; then
            mkdir $KERNEL_DIR/_BUILD_KERNEL
	fi;
    
    zip -r9 "$KERNEL_DIR/_BUILD_KERNEL/$ZIPNAME" *
    cd ..
	rm -rf AnyKernel3 
        #rm AnyKernel3/modules/vendor/lib/modules/*.ko
        #rm AnyKernel3/modules.*
        #rm AnyKernel3/Image.gz-dtb
        #rm AnyKernel3/dtbo.img

    echo -e ${bldgrn}"\nZipping succesfully! \n"${txtrst};
    echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
    echo -e ${bldylw}"Zip: $ZIPNAME" ${txtrst};
    echo -e "";
    echo -e "";
    
    rm -rf $out    
    #cp build_vers build_vers.bk
   
	echo -e "";
	echo -e "";
	echo -e ${blu}"                 _    _  _  _     _ _   _ _    "${txtrst};
	echo -e ${blu}"    _ _ _ _     / \  |  _ \| | _ / _ \/ _ _|   "${txtrst};
	echo -e ${grn}"   |  _   _ \  / _ \ | |_) | |/ / | | \_ _ \   "${txtrst};
	echo -e ${ylw}"   | | | | | |/ _,_ \|  _ <|   <| |_| |_ _) |  "${txtrst};
	echo -e ${red}"   |_| |_| |_/_/   \_\_| \_\_|\_|\_ _/ \_ _/   "${txtrst};
	echo -e ${red}"     K E R N E L • G I N K G O • W I L L O W   "${txtrst};                                
	echo -e ${blu}"                                               "${txtrst};
	echo -e ${blu}"                                               "${txtrst};
	echo -e ${ppl}"            Xiaomi Redmi Note 8/8T             "${txtrst};
	echo -e ${ppl}"            by mARk-android@github             "${txtrst};
	echo -e ${blu}"                                               "${txtrst};
	echo -e ${blu}"   ******************************************* "${txtrst}; 
	echo -e "";
	echo -e "";
	echo -e "";
	echo -e "";    
    
    
else
    echo -e ${bldred}"\nCompilation failed!\n"${txtrst};
fi;
