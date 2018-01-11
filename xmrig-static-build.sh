#!/bin/sh

export CFLAGS=" -Ofast -Flto "
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"

## getalp ; chroot alp ...
cd /
jobs=$(cat /proc/cpuinfo | grep -i "cpu cores" | wc -l)
[ -z "$jobs" ] && jobs=1
apk add alpine-sdk cmake libuv-dev
wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-latest.tar.gz
tar xf libmicrohttpd-latest.tar.gz
cd libmicrohttpd-*
./configure --enable-static --disable-shared
make -j $jobs install
cd /
git clone --depth=1 https://github.com/xmrig/xmrig
mkdir xmrig/build && cd xmrig/build || exit 1
mhdpath=$(ls -d /libmicrohttpd-*/)
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS " -static '"$CFLAGS"'")' -i ../CMakeLists.txt
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
cmake .. -DMHD_INCLUDE_DIR=${mhdpath}/src/include -DMHD_LIBRARY=/${mhdpath}/src/microhttpd/.libs/libmicrohttpd.a
make -j $jobs
