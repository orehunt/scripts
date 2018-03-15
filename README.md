# semi static xnp executable

build with pkg
```
repo=bobbieltd/xmr-node-proxy
git clone --depth=1 https://github.com/$repo
npm install
## apply patches
npm install -g pkg
pkg -t node6-linux-x64 package.json
```

works on alpine with glibc+glibc-bin packages.

