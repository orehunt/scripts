#!/bin/sh

MYLIBPATH="."
MYLDPATH="$MYLIBPATH/ld.so"
prevpath=$PWD
repo="https://github.com/Bendr0id/xmrigCC"
repo_name="$(basename "$repo")"

## alpine preferred, or voidlinux/voidlinux-musl
cd /

if type apk; then
    apk add --update alpine-sdk cmake libuv-dev libmicrohttpd-dev coreutils libressl-dev patchelf
    # LINKER="ld-musl-x86_64.so.1"
    LINKER="libc.musl-x86_64.so.1"
else
    xbps-install -Syu
    xbps-install cmake libuv-devel gcc libmicrohttpd-devel git make libressl-devel patchelf
    LINKER="ld-linux-x86-64.so.2" ## care about underscores
fi

rm -rf "$repo_name"
if [ -n "$TRAVIS_TAG" ]; then
    git clone -b "$TRAVIS_TAG" --depth=1 "$repo"
else
    git clone --depth=1 "$repo"
fi
mkdir "$repo_name/build" && cd "$repo_name/build" || exit 1


## set dynamic linker path
sed -r 's#(target_link_libraries\(xmrig[^ ]*)#\1 -Wl\,--dynamic-linker='"$MYLDPATH"' #' -i ../CMakeLists.txt
sed -r '/add_executable\(xmrigDaemon/atarget_link_libraries\(xmrigDaemon -Wl\,--dynamic-linker='"$MYLDPATH"'\)' -i ../CMakeLists.txt
## custom donation level
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h

if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
    export CC=${CC:-"$(uname -m)-linux-musl-gcc"}
fi
export MAKEFLAGS=" -j $(nproc) "
export CFLAGS=" -Ofast -Flto"
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"
## set flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS "'"$CFLAGS"'")' -i ../CMakeLists.txt

cmake ..
## some includes...
# ln -s /usr/include/openssl /xmrigCC/src/3rdparty/clib-net/include/
# ln -s /usr/include/uv* /xmrigCC/src/3rdparty/clib-net/include/
make xmrigCCServer
## this requires further cmakefile tweaking
if [ "$MYLIBPATH" = "." ]; then
    DT_RUNPATH='$ORIGIN/' LD_RUN_PATH='$ORIGIN/' RPATH='$ORIGIN/' make
else
    DT_RUNPATH='$ORIGIN/'"$MYLIBPATH" LD_RUN_PATH='$ORIGIN/'"$MYLIBPATH" RPATH='$ORIGIN/'"$MYLIBPATH" make
fi

## use patchelf to set rpath since either cmake or I don't understand how to set rpath
patchelf --set-rpath "\$ORIGIN" xmrigCCServer

mkdir -p archive && cd archive || exit 1
mkdir -p "$MYLIBPATH"
ldd ../xmrigCCServer | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' "$MYLIBPATH"
if [ -f "/lib/$LINKER" ]; then
        cp "/lib/$LINKER" "$MYLDPATH"
else
        cp "/usr/lib/$LINKER" "$MYLDPATH"
fi
cp /xmrigCC/src/config_cc.json default_config_cc.json
mkdir -p dashboard
cp /xmrigCC/index.html dashboard/index.html

ln -sr "$MYLDPATH" "$MYLIBPATH/$LINKER"
tar czf mccsrv.tar.gz ../xmrigCCServer "$MYLIBPATH"
mv mccsrv.tar.gz $prevpath/
