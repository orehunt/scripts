#!/bin/sh

if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
        export CC="/usr/bin/musl-gcc"
fi
export CFLAGS=" -Ofast -Flto "
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"

## get void ; chroot void ...
cd /
jobs=$(cat /proc/cpuinfo | grep -i "cpu cores" | wc -l)
[ -z "$jobs" ] && jobs=1

rm -rf ./libmicrohttpd-*
wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-latest.tar.gz
tar xf libmicrohttpd-latest.tar.gz
cd libmicrohttpd-* || exit 1
./configure --enable-static --disable-shared --without-gnutls

make -j $jobs install || exit 1
cd /
rm -rf /xmrigCC
git clone --depth=1 https://github.com/Bendr0id/xmrigCC
mkdir xmrigCC/build && cd xmrigCC/build || exit 1
mhdpath=$(ls -d /libmicrohttpd-*/)
## drop shell for xmrigDaemon
sed -r 's/(=)( ownPath.substr)/\1 "exec " +\2/' -i ../src/cc/XMRigd.cpp
## set flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS " -static '"$CFLAGS"'")' -i ../CMakeLists.txt
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
cmake ..  -DMHD_INCLUDE_DIR=${mhdpath}/src/include -DMHD_LIBRARY=/${mhdpath}/src/microhttpd/.libs/libmicrohttpd.a
make -j $jobs
