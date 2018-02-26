#!/bin/sh

MYLIBPATH="pl/lib"
MYLDPATH="$MYLIBPATH/ld.so"
prevpath=$PWD

## voidlinux/voidlinux-musl
cd /

if type apk; then
    apk add --update alpine-sdk cmake libuv-dev libmicrohttpd-dev coreutils
    LINKER="ld-musl-x86_64.so.1"
else
    xbps-install -Syu
    xbps-install cmake libuv-devel gcc libmicrohttpd-devel git make
    LINKER="ld-linux-x86-64.so.2" ## care about underscores
fi
rm -rf /xmrigCC
git clone --depth=1 https://github.com/Bendr0id/xmrigCC
mkdir xmrigCC/build && cd xmrigCC/build || exit 1
## set flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS "'"$CFLAGS"'")' -i ../CMakeLists.txt
## set dynamic linker path
sed -r 's#(target_link_libraries\(xmrig[^ ]*)#\1 -Wl\,--dynamic-linker='"$MYLDPATH"' #' -i ../CMakeLists.txt
sed -r '/add_executable\(xmrigDaemon/atarget_link_libraries\(xmrigDaemon -Wl\,--dynamic-linker='"$MYLDPATH"'\)' -i ../CMakeLists.txt
## drop shell for xmrigDaemon
# sed -r 's/(=)( ownPath.substr)/\1 "exec " +\2/' -i ../src/cc/XMRigd.cpp
## don't use xmrigDaemon
sed 's/m_daemonized(false)/m_daemonized(true)/' -i ../src/Options.cpp
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
patch $PWD/../src/cc/CCClient.cpp ${prevpath}/skipCommand.patch

if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
    export CC=${CC:-"$(uname -m)-linux-musl-gcc"}
fi
export MAKEFLAGS=" -j $(nproc) "
export CFLAGS=" -Ofast -Flto"
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"
cmake ..
LD_RUN_PATH='$ORIGIN/'"$MYLIBPATH" RPATH='$ORIGIN/'"$MYLIBPATH" make
mkdir -p "$MYLIBPATH"
ldd xmrig* | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' "$MYLIBPATH"
if [ -f "/lib/$LINKER" ]; then
        cp "/lib/$LINKER" "$MYLDPATH"
else
        cp "/usr/lib/$LINKER" "$MYLDPATH"
fi
ln -sr "$MYLDPATH" "$MYLIBPATH/$LINKER"
tar czf xmrig.tar.gz xmrig* "$MYLIBPATH"
