#!/bin/sh

export CFLAGS=" -Ofast -Flto "
export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" LDFLAGS="$CFLAGS"

MYLIBPATH="pl/lib"
MYLDPATH="$MYLIBPATH/ld.so"

## getalp ; chroot alp ...
cd /
export MAKEFLAGS=" -j $(nproc) "
apk add --no-cache alpine-sdk cmake libuv-dev libmicrohttpd-dev
git clone --depth=1 https://github.com/xmrig/xmrig
mkdir xmrig/build && cd xmrig/build || exit 1
sed '/add_executable/iset(CMAKE_EXE_LINKER_FLAGS "'"$CFLAGS"'")' -i ../CMakeLists.txt
sed -r 's#(target_link_libraries\(xmrig)#\1 -Wl\,--dynamic-linker='"$MYLDPATH"' #' -i ../CMakeLists.txt
sed -r 's/(kDonateLevel = )([0-9]+)/\10/' -i ../src/donate.h
cmake ..
LD_RUN_PATH='$ORIGIN/'"$MYLIBPATH" RPATH='$ORIGIN/'"$MYLIBPATH" make
mkdir -p "$MYLIBPATH"
ldd xmrig | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' "$MYLIBPATH"
cp -a /lib/libc.musl-x86_64.so.1 "$MYLIBPATH"
cp -a /lib/ld-* "$MYLDPATH"
tar czf xmrig.tar.gz xmrig "$MYLIBPATH"
