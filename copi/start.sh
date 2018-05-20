#!/bin/sh -l

DIR=$(dirname $(realpath "$0"))
export PATH="$DIR:$PATH"
type copi || { echo "containerpilot not found, aborting."; exit 1; }
type hpr || { echo "haproxy not found, aborting."; exit 1; }

copi_config=copi.json5
hpr_config=hpr.cfg
copi -config $copi_config -template -out run.$copi_config
copi -config $hpr_config -template -out $hpr_config
# exec copi -config run.$copi_config
copi -config run.$copi_config
