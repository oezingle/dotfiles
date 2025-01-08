#!/bin/sh

CONFIG=$1

if [[ -z $1 ]]; then
    CONFIG="$PWD/rc.lua"
fi

Xephyr :4 & sleep 0.01; DISPLAY=:4 awesome -c $CONFIG