#!/bin/zsh

[ -z "$1" ] &&
	echo "provide a file to obfuscate." && 
	exit 1

tool=bash-obfuscate
outf="${1}.obfs"

[ -f /tmp/.obfs-installed ] || npm list -g "$tool" || { npm install -g "$tool" && touch /tmp/.obfs-installed }
echo 'set +x' > "$outf"
$tool -r "$1" >> "$outf"
## | sed 's/eval/exec bash <<< /' >> "$outf" &&
echo "file $outf is obfuscated"
