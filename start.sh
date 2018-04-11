#!/bin/sh

AES_AVL=$(cat /proc/cpuinfo | grep -o -m1 aes)
KRN=$(uname -r)
DIR=$(dirname $(realpath "$0"))
PATH="$DIR:$PATH"
proot=wrap

cd $DIR
if [ -z "$AES_AVL" ]; then
    mvpath="node_modules/multi-hashing/build/Release"
    mv ${mvpath}/multihashing_nan.node \
       ${mvpath}/multihashing.node
fi

if [ "$KRN" != "${KRN/2.6}" ]; then ## hide kernel if too old
    LD_LIBRARY_PATH=$DIR/lib \
                   PATH=$DIR/lib:$PATH \
               exec $proot -k 4.14 xnp 2>/dev/null
else
    LD_LIBRARY_PATH=$DIR/lib \
                   PATH=$DIR/lib:$PATH \
                   exec xnp 2>/dev/null
fi
