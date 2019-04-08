#!/bin/zsh

# data=$(</dev/stdin)
[ -z "$TOCF" ] && echo specify file with var \$TOCF && exit
chunk_size=2047 ## 1 char for order
# data=$(echo "$data" | base64 -w $chunk_size)
data=$(base64 -w $chunk_size "$TOCF")
if [ -n "$1"  ]; then
    zone=drun.ml
    record="$1"
    if [ -n "$2" ]; then
        zone="$2"
    fi
else
    zone=drun.ml
    record=d
fi
type=txt

get_record_ids() {
    flarectl dns list --zone drun.ml --name $record.$zone | awk ' NR > 2 { print $1 }'
}

delete_record() {
    local IFS=$'\n'
    for i in ${=1}; do
        flarectl dns delete --zone $zone --id $i
    done
}

create_record() {
    [ -n "$2" ] && { record=$1 && content=$2; } || content=$1
    [ -z "$*" ] && return
    flarectl dns create \
             --zone $zone \
             --name $record \
             --type $type \
             --content "$content" | grep "undocumented error" && return 1
}

ids=$(get_record_ids)
delete_record $ids

done=1
replay=
IFS=$'\n'
c=0
for chunk in ${=data}; do
    [ $c -gt 9 ] && { echo too many chunks, max 9; echo exit 1; }
  echo creating record $c size $(echo -n "$c$chunk" | wc -c)
  # create_record "d$c" "$c$chunk"
  create_record "$c$chunk"
  c=$((c+1))
done
