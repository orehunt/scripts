#!/bin/bash
## make sure to compile multihashing.node on an intel cpu for extensions compatibility
set -e
nodeV=8
fork=https://github.com/bobbieltd/xmr-node-proxy
bpath=node_modules/multi-hashing/build/Release
# modules="{bignum,cryptonote-util,multi-hashing}"
# modules="{bignum,cryptoforknote-util,cryptonight-hashing,multi-hashing,cryptonote-util,semipool-ipbc-util}"
export DEBIAN_FRONTEND=noninteractive
name=xnp
appname=server.js

apt update && apt upgrade -y
apt -y install git python-virtualenv python3-virtualenv curl ntp build-essential screen cmake pkg-config libboost-all-dev libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev libzmq3-dev
rm -rf $name
git clone $fork $name
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v$nodeV

## rename folder and main bin for pkg children procs
cd $name
export JOBS=max
npm install --ignore-scripts
find ./ -name binding.gyp | xargs sed 's/-march=native/-mtune=generic -maes/' -i
npm install
npm rebuild
npm install -g pkg@4.2.5
mv proxy.js $appname
patch package.json ../package.json.patch
patch $appname ../proxy.js.patch
sed 's/sendReply(miner.error)/if (miner.error != "Unauthorized access" ) sendReply(miner.error)/' \
    -i $appname
pkg -t node$nodeV-linux-x64 package.json -o pkgbin
rm -rf bindings/ && mkdir bindings && \
find node_modules \
     -regextype sed -regex ".*Release/[^\/]*.node" | \
        xargs -I{} cp --parents -a {} bindings/
mv pkgbin ../
rm -rf ../bindings
mv bindings ../
cd ../ && rm -rf $name && mv pkgbin $name

