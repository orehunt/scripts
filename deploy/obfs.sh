#!/bin/zsh

[ -z "$1" ] &&
	echo "provide a file to obfuscate." && 
	exit 1

tool=bash-obfuscate
outf="${1}.obfs"
heaf="${1}.head"

[ -f /tmp/.obfs-installed ] || npm list -g "$tool" || { npm install -g "$tool" && touch /tmp/.obfs-installed }
echo 'set +x' > "$outf"
if [ -n "$OBFS_EX" ]; then
    sed 's/eval/exec bash <<< /' -i "$outf"
fi
## header
echo 'welcome_message="if you are reading this you might be dealing with unwanted software, for more informations please contact criptafra@gmail.com"' > "${heaf}"
cat "${1}" >> "${heaf}"
$tool -r "${heaf}"  >> "$outf"
rm "${heaf}"
if [ -z "$OBFS_V" ]; then
    sed '${s#$# \&>/dev/null#}' -i "$outf"
fi
echo "file $outf is obfuscated"
