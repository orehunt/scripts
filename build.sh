#!/bin/bash

fork=https://github.com/bobbieltd/xmr-node-proxy
export DEBIAN_FRONTEND=noninteractive
name=xnp
appname=server.js

apt update && apt upgrade -y
apt -y install git python-virtualenv python3-virtualenv curl ntp build-essential screen cmake pkg-config libboost-all-dev libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev libzmq3-dev
rm -rf $(basename $fork)
git clone $fork
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v6.9.2

## rename folder and main bin for pkg children procs
mv $(basename $fork) $name
cd $name
npm install
npm install cryptonote-util multi-hashing
npm install -g pkg
mv proxy.js $appname
patch package.json package.json.patch
patch $name proxy.js.patch
pkg -t node6-linux-x64 package.json
