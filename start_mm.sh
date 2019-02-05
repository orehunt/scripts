#!/bin/bash -l

KRN="$(uname -r)"
DIR=$(dirname $(realpath "$0"))
PATH="$DIR:$PATH"
proot=wrap

consul_kv="http://localhost:3424/v1/kv"
config_k="xnp/config_mm"
config=
try=0

while [ -z "$config" -a $try -lt 3 ]; do
    config=$(wget -qO- "$consul_kv/$config_k" | sed -r 's/.*Value":"([^"]*)".*/\1/' | base64 -d)
    try=$((try+1))
    sleep 1
done

if [ -z "$config" -o "$?" != 0 ]; then
    echo "error fetching config from kv store!"
    if [ ! -e mm.json ]; then
        echo "no config present on disk, aborting."
        exit 1
    fi
fi

cd "$DIR"
echo "$config" > mm.json

if [ "${KRN}" != "${KRN/2.6}" ]; then ## hide kernel if too old
# if false; then ## hide kernel if too old
    PATH=$DIR/lib:$PATH \
        exec $proot -k 10 mm # 2>/dev/null
else
    PATH=$DIR/lib:$PATH \
        exec mm # 2>/dev/null
fi
