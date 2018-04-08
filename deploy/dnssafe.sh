#!/bin/zsh

if [ -n "$1" ]; then
    string=$(cat "$1" |\
	               base64 -w 128 |\
	               sed ':a;N;$!ba;s/\n/" "/g' |\
	               sed 's/=$/eql/')
    echo "\"$string\""
else
    echo -n \"
    base64 -w 128 </dev/stdin |\
	      sed ':a;N;$!ba;s/\n/" "/g' |\
	      sed 's/=$/eql/' | tr '\n$' '"'
fi
