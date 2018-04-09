#!/bin/bash
## make sure to compile multihashing.node on an intel cpu for extensions compatibility
set -e
fork=https://github.com/bobbieltd/xmr-node-proxy
bpath=node_modules/multi-hashing/build/Release
# modules="{bignum,cryptonote-util,multi-hashing}"
modules="{bignum,cryptoforknote-util,cryptonight-hashing}"
export DEBIAN_FRONTEND=noninteractive
name=xnp
appname=server.js

apt update && apt upgrade -y
apt -y install git python-virtualenv python3-virtualenv curl ntp build-essential screen cmake pkg-config libboost-all-dev libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev libzmq3-dev
rm -rf $name
git clone $fork $name
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v8

## rename folder and main bin for pkg children procs
cd $name
npm install --nobuild
find ./ -name binding.gyp | xargs sed 's/-march=native/-mtune=generic -maes/' -i
npm build
npm install -g pkg@4.2.5
mv proxy.js $appname
patch package.json ../package.json.patch
patch $appname ../proxy.js.patch
sed -r "s/multi-hashing/cryptonight-hashing/" -i lib/*.js
pkg -t node8-linux-x64 package.json -o pkgbin
rm -rf bindings/ && mkdir bindings && \
    eval "find node_modules/$modules \
         -name \*.node ! -path \*obj.target\*" | \
        xargs -I{} cp --parents -a {} bindings/
mv pkgbin ../
rm -rf ../bindings
mv bindings ../
cd ../ && rm -rf $name && mv pkgbin $name

