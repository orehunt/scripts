#!/bin/sh

LIBC=${LIBC:-musl}
DIR=$(dirname $(realpath "$0"))
PATH="$DIR:$PATH"
cd $DIR
LD_LIBRARY_PATH=$DIR/lib/$LIBC \
               exec xnp
