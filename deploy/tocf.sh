#!/bin/zsh

data=$(</dev/stdin)
chunk_size=2047 ## 1 char for order
data=$(echo "$data" | base64 -w $chunk_size)
zone=drun.ml
record=d
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
    [ -z "$*" ] && return
    flarectl dns create \
             --zone $zone \
             --name $record.$zone \
             --type $type \
             --content "$*"
}

ids=$(get_record_ids)
delete_record $ids

done=1
replay=
IFS=$'\n'
c=0
for chunk in ${=data}; do
    [ $c -gt 9 ] && exit 1
  create_record "$c$chunk"
  c=$((c+1))
done
