#!/usr/bin/env bash
#
set wd /tmp/testing
rm -rf $wd
cp -a $PWD $wd
dkr run --rm -it -v $wd:$wd -w $wd ubuntu /bin/bash
