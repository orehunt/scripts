#!/bin/sh -l

DIR=$(dirname $(realpath "$0"))
export PATH="$DIR:$PATH"
type copi || { echo "containerpilot not found, aborting."; sleep 3; exit 1; }
type hpr || { echo "haproxy not found, aborting."; sleep 3; exit 1; }
# getent passwd haproxy ||  adduser -D haproxy || { echo "haproxy user not found and couldn't be added"; sleep 3; exit 1; }

copi_config=copi.json5
hpr_config=hpr.cfg
copi -config $copi_config -template -out run.$copi_config
copi -config $hpr_config -template -out run.$hpr_config
exec copi -config run.$copi_config
