#!/bin/sh

DIR=$(dirname $(realpath "$0"))
PATH="$DIR:$PATH"
cd $DIR
LD_LIBRARY_PATH=$DIR \
               exec xnp
