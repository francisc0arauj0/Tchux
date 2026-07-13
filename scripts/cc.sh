#!/bin/sh
set -e

clear

NO_FORMAT="\033[0m"
C_RED="\033[38;5;9m"
C_LIME="\033[38;5;10m"
C_YELLOW="\033[38;5;11m"

case "$1" in
	x86_64-elf) TARGET=x86_64-elf ;;
	i686-elf) TARGET=i686-elf ;;
	*)

		echo "${C_RED}Invalid architecture.${NO_FORMAT}\n"
		echo "Use:"
		echo "$0 x86_64-elf"
		echo "$0 i686-elf\n"
		exit 1
		;;
esac

if [ -z "$2" ]; then
	echo "${C_RED}Installation directory missing.${NO_FORMAT}\n"
	echo "Use:"
	echo "$0 $TARGET /home/your_user/Tchux/txcc\n"
	exit 1
fi

BINUTILS=2.45
GCC=16.1.0
GDB=17.2
JOBS=$(nproc)
PREFIX="$(realpath "$2")"

echo "${C_YELLOW}============================"
echo "TxCC Info"
echo Binutils Version: $BINUTILS
echo GCC Version: $GCC
echo GDB Version: $GDB
echo NProc: $JOBS
echo "============================\n${NO_FORMAT}"

sleep 2

mkdir txcc
cd txcc

echo "${C_YELLOW}[1/8] Creating directories...\n${NO_FORMAT}"

mkdir -p cross_tmp/binutils
mkdir -p cross_tmp/gcc
mkdir -p cross_tmp/gdb

cd cross_tmp/binutils

echo "${C_YELLOW}[2/8] Downloading Binutils...\n${NO_FORMAT}"
wget -nc https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS.tar.xz
tar -xf binutils-$BINUTILS.tar.xz
rm -rf binutils-$BINUTILS.tar.xz

cd ../gcc # cross_tmp/gcc

echo "${C_YELLOW}[3/8] Downloading GCC...\n${NO_FORMAT}"
wget -nc https://ftp.gnu.org/gnu/gcc/gcc-$GCC/gcc-$GCC.tar.xz
tar -xf gcc-$GCC.tar.xz
rm -rf gcc-$GCC.tar.xz

echo "${C_YELLOW}[4/8] Downloading GCC dependencies...\n${NO_FORMAT}"
cd gcc-$GCC
./contrib/download_prerequisites

cd ../../gdb # cross_tmp/gdb

echo "\n${C_YELLOW}[5/8] Downloading GDB...\n${NO_FORMAT}"
wget -nc https://ftp.gnu.org/gnu/gdb/gdb-$GDB.tar.xz
tar -xf gdb-$GDB.tar.xz
rm -rf gdb-$GDB.tar.xz

cd ../binutils # cross_tmp/binutils

# https://wiki.osdev.org/GCC_Cross-Compiler#Binutils
echo "${C_YELLOW}[6/8] Compiling/Installing Binutils...\n${NO_FORMAT}"

binutils-$BINUTILS/configure \
	--target=$TARGET \
	--prefix=$PREFIX \
	--with-sysroot \
	--disable-nls \
	--disable-werror \
	--enable-default-execstack=no

make -j$JOBS
make install

# https://wiki.osdev.org/GCC_Cross-Compiler#GCC
echo "${C_YELLOW}[7/8] Compiling/Installing GCC...\n${NO_FORMAT}"

cd ../gcc # cross_tmp/gcc

gcc-$GCC/configure \
	--target=$TARGET \
    --prefix=$PREFIX \
	--disable-nls \
	--enable-languages=c \
	--without-headers \
	--enable-initfini-array \
	--disable-hosted-libstdcxx

make all-gcc -j$JOBS
make all-target-libgcc -j$JOBS
make install-gcc
make install-target-libgcc

# https://wiki.osdev.org/GCC_Cross-Compiler#GDB
echo "${C_YELLOW}[8/8] Compiling/Installing GDB...${NO_FORMAT}"

cd ../gdb # cross_tmp/gdb

gdb-$GDB/configure \
	--target=$TARGET \
    --prefix=$PREFIX \
	--disable-werror

make all-gdb -j$JOBS
make install-gdb

clear

echo "============================"
echo "${C_LIME}TxCC installed!\n${NO_FORMAT}"
echo "Local: $PREFIX\n"
echo "Verification:"
echo "txcc/bin/$TARGET-ld --version"
echo "txcc/bin/$TARGET-gcc --version"
echo "txcc/bin/$TARGET-gdb --version"
echo "============================"