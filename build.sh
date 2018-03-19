#!/bin/bash
## make sure to compile multihashing.node on an intel cpu for extensions compatibility

fork=https://github.com/bobbieltd/xmr-node-proxy
bpath=node_modules/multi-hashing/build/Release
export DEBIAN_FRONTEND=noninteractive
name=xnp
appname=server.js

apt update && apt upgrade -y
apt -y install git python-virtualenv python3-virtualenv curl ntp build-essential screen cmake pkg-config libboost-all-dev libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev libzmq3-dev
rm -rf $name
git clone $fork $name
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v6.9.2

## rename folder and main bin for pkg children procs
cd $name
npm install
npm install -g pkg
mv proxy.js $appname
patch package.json ../package.json.patch
patch $appname ../proxy.js.patch
pkg -t node6-linux-x64 package.json -o pkgbin
rm -rf bindings/ && mkdir bindings && \
    find node_modules/{bignum,cryptonote-util,multi-hashing} \
         -name \*.node ! -path \*obj.target\* | \
        xargs -I{} cp --parents -a {} bindings/
patch package.json ../package.json_nan.patch
npm install multi-hashing
cp ${bpath}/*.node bindings/${bpath}/multihashing_nan.node
mv pkgbin ../
rm -rf ../bindings
mv bindings ../
cd ../ && rm -rf $name && mv pkgbin $name
