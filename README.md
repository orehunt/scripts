# semi static xnp executable

To make the executable, edit in proxy.js:
```
global.require('cluster');
```
```
this.coinFuncs = global.require(`./lib/${this.coin}.js`)();
```
Build with
```
npm install -g nexe
nexe proxy.js -o proxy
```
files in `lib/` are needed, no point in including them (and certs) in the bin since runtime bin libs (ldd) are also needed so it still wouldn't be a static bin.
```
also bindings are needed (*.node)
```
find node_modules/{bignum,cryptonote-utils,multi-hashing} -name \*.node | xargs -I{} cp -a {} scripts/
find scripts/node_modules/ -type f -not -name \*.node | xargs -I{} rm {}
```
