#!/bin/bash

## *** SUPERSEDED BY FLARECTL ***

# CHANGE THESE
auth_email=""
auth_key="" # found in cloudflare account settings
zone_name="<domain>"
record_name="$1.<domain>"
#type=A
type=TXT
value=$2

# MAYBE CHANGE THESE
#ip=$(curl -s http://ipv4.icanhazip.com)
#ip_file="ip.txt"
id_file="cloudflare.ids"
#log_file="cloudflare.log"

# LOGGER
log() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" >> $log_file
    fi
}

# SCRIPT START
# log "Check Initiated"

#if [ -f $ip_file ]; then
#    old_ip=$(cat $ip_file)
#    if [ $ip == $old_ip ]; then
#        echo "IP has not changed."
#        exit 0
#    fi
#fi

#if [ -f $id_file ] && [ $(wc -l $id_file | cut -d " " -f 1) == 2 ]; then
#    zone_identifier=$(head -1 $id_file)
#    record_identifier=$(tail -1 $id_file)
#else
    zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | sed -r 's/\{"result":\[\{"id":"([^"]*).*/\1/')
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json"  | sed -r -e 's/.*"id":"([^"]*).*/\1/')
    echo "$zone_identifier" > $id_file
    echo "$record_identifier" >> $id_file
#fi

update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"id\":\"$zone_identifier\",\"type\":\"$type\",\"name\":\"$record_name\",\"content\":\"$value\"}")

if [[ $update == *"\"success\":false"* ]]; then
    message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
    #log "$message"
    echo -e "$message"
    exit 1 
else
	:
    #message="IP changed to: $ip"
    #echo "$ip" > $ip_file
    #log "$message"
    #echo "$message"
fi
