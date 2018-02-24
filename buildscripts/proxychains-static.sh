#!/bin/sh

git clone --depth=1 https://github.com/rofl0r/proxychains-ng
cd proxychains-ng || exit 1
./configure --ignore-cve --libdir=pl
CFLAGS="-O3 -static" LDFLAGS="-O3 -static" make -j $(nproc)
