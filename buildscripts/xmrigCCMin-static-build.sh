#!/bin/sh

## distro pkgs
if type apk; then
    apk add --update alpine-sdk cmake libuv-dev coreutils libressl-dev
else
    xbps-install -Syu
    xbps-install cmake libuv-devel gcc git make libressl-devel
fi

## get void ; chroot void ...
cd /
jobs=$(nproc || cat /proc/cpuinfo | grep -i "cpu cores" | wc -l)
[ -z "$jobs" ] && jobs=1

rm -rf /xmrigCC
git clone --depth=1 https://github.com/Bendr0id/xmrigCC
mkdir xmrigCC/build && cd xmrigCC/build || exit 1

## drop shell for xmrigDaemon
# sed -r 's/(=)( ownPath.substr)/\1 "exec " +\2/' -i ../src/cc/XMRigd.cpp
## skip daemon flag
sed 's/m_daemonized(false)/m_daemonized(true)/' -i ../src/Options.cpp
## donation level
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
## skip pause patch
patch $PWD/../src/cc/CCClient.cpp ${prevpath}/skipCommand.patch

## build
if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
    export CC=${CC:-"$(uname -m)-linux-musl-gcc"}
fi
export MAKEFLAGS=" -j $(nproc) "
export CFLAGS=" -Ofast -Flto"
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"
## set build flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS " -static '"$CFLAGS"'")' -i ../CMakeLists.txt

cmake ..
make -j $jobs xmrigMiner
mv xmrigMiner xmrig
