#!/bin/sh

MYLIBPATH="."
# MYLDPATH="$MYLIBPATH/ld.so"
prevpath=$PWD
repo="https://github.com/Bendr0id/xmrigCC"
repo_name="$(basename "$repo")"

## alpine preferred, or voidlinux/voidlinux-musl
cd /

if type apk; then
    ## add testing repository
    t_repo="$(cat /etc/apk/repositories | tail -1 | sed 's/community/testing/')"
    echo "$t_repo" >> /etc/apk/repositories
    apk add --update alpine-sdk cmake libuv-dev libmicrohttpd-dev coreutils libressl-dev patchelf hwloc-dev
    # LINKER="ld-musl-x86_64.so.1"
    # LINKER="libc.musl-x86_64.so.1"
else
    xbps-install -Syu
    xbps-install cmake libuv-devel gcc libmicrohttpd-devel git make libressl-devel patchelf hwloc-dev
    # LINKER="ld-linux-x86-64.so.2" ## care about underscores
fi

rm -rf "$repo_name"
if [ -n "$TRAVIS_TAG" ]; then
    git clone -b "$TRAVIS_TAG" --depth=1 "$repo"
else
    git clone --depth=1 "$repo"
fi
mkdir "$repo_name/build" && cd "$repo_name/build" || exit 1


## set dynamic linker path
# sed -r 's#(target_link_libraries\(xmrig[^ ]*)#\1 -Wl\,--dynamic-linker='"$MYLDPATH"' #' -i ../CMakeLists.txt
# sed -r '/add_executable\(xmrigDaemon/atarget_link_libraries\(xmrigDaemon -Wl\,--dynamic-linker='"$MYLDPATH"'\)' -i ../CMakeLists.txt
## custom donation level
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h

if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
    export CC=${CC:-"$(uname -m)-linux-musl-gcc"}
fi
export MAKEFLAGS=" -j $(nproc) xmrigServer"
export CFLAGS=" -Ofast -Flto -static"
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"
## set flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS "'"$CFLAGS"'")' -i ../CMakeLists.txt

cmake .. \
      -DCMAKE_LINK_SEARCH_START_STATIC=ON \
      -DCMAKE_LINK_SEARCH_END_STATIC=ON \
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      -DWITH_CC_SERVER=ON -DWITHOUT_CC_CLIENT=ON \
      -DWITH_HWLOC=OFF -DWITH_HTTP=OFF \
      -DOPENSSL_SSL_LIBRARY=/usr/lib/libssl.a \
      -DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.a \
      -DBUILD_STATIC=ON
# ## some includes...
# # ln -s /usr/include/openssl /xmrigCC/src/3rdparty/clib-net/include/
# # ln -s /usr/include/uv* /xmrigCC/src/3rdparty/clib-net/include/
make xmrigServer

mkdir -p archive && cd archive || exit 1
cp /xmrigCC/src/config_cc.json default_config_cc.json
mkdir -p dashboard
cp /xmrigCC/index.html dashboard/index.html
mv ../xmrigServer mccsrv

tar czf mccsrv.tar.gz . "$MYLIBPATH"
mv mccsrv.tar.gz $prevpath/
