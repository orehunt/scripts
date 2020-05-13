#!/bin/sh

set -e

prevpath=$PWD
repo="https://github.com/Bendr0id/xmrigCC"
# repo="https://github.com/untoreh/xmrigCC"
branch="-b master"
repo_name="$(basename "$repo")"

if [ "$1" = mac ]; then
    brew install bash gnu-sed gpatch gcc cmake libuv openssl libmicrohttpd boost || true # rclone
    PATH=/usr/local//Cellar/gnu-sed/4.6/libexec/gnubin/:$PATH
    sed=gsed
else
    sed=sed
fi

## distro pkgs
if type apk; then
    #apk --allow-untrusted del -f openssl-dev
    apk --allow-untrusted add openssl-dev openssl-libs-static libuv-static
    apk --allow-untrusted add -f --update alpine-sdk cmake hwloc-dev libuv-dev libuv-static coreutils libmicrohttpd-dev boost-dev boost-static g++ patchelf
fi

## get void ; chroot void ...
prevpath=${PWD}
cd ~/
if [ "$1" = mac ]; then
    jobs=$(sysctl -n hw.physicalcpu)
else
    jobs=$(nproc || cat /proc/cpuinfo | grep -i "cpu cores" | wc -l)
fi
[ -z "$jobs" ] && jobs=1

rm -rf "$repo_name"
ttag="${TRAVIS_TAG/-*}"
if [ -n "$ttag" ]; then
    git clone -b "ttag" --depth=1 "$repo"
else
    git clone --depth=1 "$repo" $branch
fi

# cd xmrigCC; git checkout 1.8.2; cd -
mkdir "$repo_name/build" && cd "$repo_name/build" || exit 1

## drop shell for xmrigDaemon
# sed -r 's/(=)( ownPath.substr)/\1 "exec " +\2/' -i ../src/cc/XMRigd.cpp
## skip pause patch
# patch $PWD/../src/cc/CCClient.cpp ${prevpath}/classic_patches/skipCommand.patch
# patch $PWD/../src/Options.cpp ${prevpath}/classic_patches/options.cpp.patch
# patch $PWD/../src/Options.h ${prevpath}/classic_patches/options.h.patch
# patch $PWD/../src/workers/MultiWorker.cpp ${prevpath}/classic_patches/multiworker.cpp.patch
# patch $PWD/../src/net/Client.cpp ${prevpath}/classic_patches/client.cpp.patch
BACKIFS=$IFS; IFS=$'\n'
# set -x
cd ../
patch -s -p1 < "${prevpath}/custom.patch"
cd -
# for pa in $(find ${prevpath} -maxdepth 1 -name '*.patch'); do
#     orig=$(awk '/--- /{ ok = gsub(/--- a\/|.orig/, ""); print}' < $pa)
#     patch "${PWD}/../${orig}" "${pa}"
# done
IFS=$BACKIFS

## skip daemon flag
# $sed 's/m_daemonized(false)/m_daemonized(true)/' -i ../src/Options.cpp
## donation level
$sed -r 's/(kDefaultDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
$sed -r 's/(kMinimumDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h

## algo tweaks
$sed -r 's/"upx2"/"cn-femto\/upx2"/' -i ../src/base/crypto/Algorithm.cpp

## build
if [ "$1" != mac ]; then
    if [ -z "$(ldd $(which gcc) | grep -i musl)" ]; then
        export CC=${CC:-"$(uname -m)-linux-musl-gcc"}
    fi
fi
export MAKEFLAGS=" -j $jobs "
if [ "$1" = mac ]; then
    export CFLAGS=" -Ofast"
else
    export CFLAGS=" -Ofast -Flto"
fi
# export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"
## set build flags
if [ "$1" != mac ]; then
    # $sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS " -static '"$CFLAGS"'")' -i ../CMakeLists.txt
    $sed -r '/target_link_libraries\(xmrigMiner xmrig_common/{n;s#(.*?)\)#\1 /usr/lib/libstdc++.a /usr/lib/libc.a -static )#}' -i ../CMakeLists.txt
fi

if [ "$1" != mac ]; then
    cmake .. \
          -DCMAKE_LINK_SEARCH_START_STATIC=ON \
          -DCMAKE_LINK_SEARCH_END_STATIC=ON \
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
          -DWITH_CC_SERVER=OFF \
          -DWITH_HWLOC=OFF -DWITH_HTTP=OFF \
          -DOPENSSL_SSL_LIBRARY=/usr/lib/libssl.a \
          -DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.a \
          -DBUILD_STATIC=ON
          # -DUV_LIBRARY=/usr/lib/libuv.a
else
    cmake .. -DUV_LIBRARY=/usr/local/lib/libuv.a \
          -DOPENSSL_SSL_LIBRARY=/usr/local/opt/openssl/lib/libssl.a \
          -DOPENSSL_CRYPTO_LIBRARY=/usr/local/opt/openssl/lib/libcrypto.a \
          -DBOOST_ROOT=/usr/local/lib \
          -DWITH_CC_SERVER=OFF \
          -DWITH_HTTPD=OFF \
          -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl \
          -DWITH_ASM=OFF
fi

## cmake fixes
# cp -a src/crypto/asm/* ../src/crypto/asm || true

# make -j $jobs xmrigMiner
make -j $jobs

if [ "$1" != mac ]; then
    mv xmrigMiner $prevpath/mcc
else
    mv xmrigMiner $prevpath/mcc_osx
fi
