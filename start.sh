#!/bin/sh -l

AES_AVL=$(cat /proc/cpuinfo | grep -o -m1 aes)
KRN="$(uname -r)"
DIR=$(dirname $(realpath "$0"))
PATH="$DIR:$PATH"
sh fix_links.sh
proot=wrap

consul_kv="http://localhost:3424/v1/kv"
config_k="xnp/config"
config=
try=0

while [ -z "$config" -a $try -lt 3 ]; do
    config=$(wget -qO- "$consul_kv/$config_k" | sed -r 's/.*Value":"([^"]*)".*/\1/' | base64 -d)
    try=$((try+1))
    sleep 1
done

if [ -z "$config" -o "$?" != 0 ]; then
    echo "error fetching config from kv store!"
    if [ ! -e config.json ]; then
        echo "no config present on disk, aborting."
        exit 1
    fi
fi

cd $DIR
if [ -n "$config" ]; then
    echo "$config" > config.json
    containerpilot -template -config config.json -out config.json
fi

if [ -z "$AES_AVL" ]; then
    mvpath="node_modules/multi-hashing/build/Release"
    mv ${mvpath}/multihashing_nan.node \
       ${mvpath}/multihashing.node
fi

if [ "${KRN}" != "${KRN/2.6}" ]; then ## hide kernel if too old
# if false; then ## hide kernel if too old
    LD_LIBRARY_PATH=$DIR/lib \
                   PATH=$DIR/lib:$PATH \
               exec $proot -k 10 xnp # 2>/dev/null
else
    LD_LIBRARY_PATH=$DIR/lib \
                   PATH=$DIR/lib:$PATH \
                   exec xnp # 2>/dev/null
fi
