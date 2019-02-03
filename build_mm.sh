#!/bin/bash

set -e
nodeV=8
fork=https://github.com/MoneroOcean/meta-miner
export DEBIAN_FRONTEND=noninteractive

name=mm
apt update && apt upgrade -y
apt -y install curl
rm -rf $name

git clone $fork $name
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v$nodeV

# pwd
# echo "copying mm_package.json to ${name}/package.json"
cp ./mm_package.json ${name}/package.json
cd $name
npm install -g pkg
pkg -t node$nodeV-linux-x64 package.json -o pkgbin
mv pkgbin ../
cd ../ && rm -rf $name && mv pkgbin $name
