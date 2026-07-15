#!/bin/sh
set -e

clear

TARGET=x86_64-elf
BINUTILS=2.45
GCC=16.1.0
JOBS=$(nproc)
PREFIX="$(pwd)/txcc"
TMP_FOLDER="cross_tmp"

mkdir $PREFIX
cd $PREFIX

mkdir -p $TMP_FOLDER/binutils
mkdir -p $TMP_FOLDER/gcc
mkdir -p $TMP_FOLDER/gdb

#################################
# Download and Install Binutils #
#################################

cd $TMP_FOLDER/binutils

wget -nc https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS.tar.xz
tar -xf binutils-$BINUTILS.tar.xz
rm -rf binutils-$BINUTILS.tar.xz


# https://wiki.osdev.org/GCC_Cross-Compiler#Binutils

binutils-$BINUTILS/configure \
	--target=$TARGET \
	--prefix=$PREFIX \
	--with-sysroot \
	--disable-nls \
	--disable-werror \
	--enable-default-execstack=no

make -j$JOBS
make install

############################
# Download and Install GCC #
############################

cd ../gcc

wget -nc https://ftp.gnu.org/gnu/gcc/gcc-$GCC/gcc-$GCC.tar.xz
tar -xf gcc-$GCC.tar.xz
rm -rf gcc-$GCC.tar.xz

cd gcc-$GCC
./contrib/download_prerequisites

# https://wiki.osdev.org/GCC_Cross-Compiler#GCC

cd ../../gcc

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

clear

echo "============================"
echo "TxTools installed!\n"
echo "Local: $PREFIX\n"
echo "Verification:"
echo "$PREFIX/bin/$TARGET-ld --version"
echo "$PREFIX/bin/$TARGET-gcc --version"
echo "============================"