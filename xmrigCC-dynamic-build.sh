#!/bin/sh

if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
    export CC="/usr/bin/musl-gcc"
fi
export CFLAGS=" -Ofast -Flto "
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"

LINKER="ld-musl-x86_64.so.1"
MYLIBPATH="pl/lib"
MYLDPATH="$MYLIBPATH/ld.so"

## voidlinux/voidlinux-musl
cd /
export MAKEFLAGS=" -j $(nproc) "
xbps-install -Syu
xbps-install cmake libuv-devel gcc libmicrohttpd-devel git make
rm -rf /xmrigCC
git clone --depth=1 https://github.com/Bendr0id/xmrigCC
mkdir xmrigCC/build && cd xmrigCC/build || exit 1
## set flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS "'"$CFLAGS"'")' -i ../CMakeLists.txt
## set dynamic linker path
sed -r 's#(target_link_libraries\(xmrig[^ ]*)#\1 -Wl\,--dynamic-linker='"$MYLDPATH"' #' -i ../CMakeLists.txt
sed -r '/add_executable\(xmrigDaemon/atarget_link_libraries\(xmrigDaemon -Wl\,--dynamic-linker='"$MYLDPATH"'\)' -i ../CMakeLists.txt
## drop shell for xmrigDaemon
sed -r 's/(=)( ownPath.substr)/\1 "exec " +\2/' -i ../src/cc/XMRigd.cpp
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
cmake ..
LD_RUN_PATH='$ORIGIN/'"$MYLIBPATH" RPATH='$ORIGIN/'"$MYLIBPATH" make
mkdir -p "$MYLIBPATH"
ldd xmrig* | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' "$MYLIBPATH"
cp "/lib/$LINKER" "$MYLDPATH"
ln -sr "MYLDPATH" "$MYLIBPATH/$LINKER"
tar czf xmrig.tar.gz xmrig* "$MYLIBPATH"
