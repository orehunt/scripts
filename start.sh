#!/bin/sh

AES_AVL=$(cat /proc/cpuinfo | grep -o -m1 aes)
LIBC=${LIBC:-musl}
# LIBC=${LIBC:-glib}
DIR=$(dirname $(realpath "$0"))
PATH="$DIR:$PATH"
cd $DIR
if [ -z "$AES_AVL" ]; then
    mvpath="node_modules/multi-hashing/build/Release"
    mv ${mvpath}/multihashing_nan.node \
       ${mvpath}/multihashing.node
fi
LD_LIBRARY_PATH=$DIR/lib/$LIBC \
               exec xnp
