#!/bin/sh

DIR=$(dirname $(realpath "$0"))
tmux new -d -s xnp $DIR/start.sh
