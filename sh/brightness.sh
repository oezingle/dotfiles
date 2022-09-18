#!/bin/bash

MODE=$1

AMT=$2

function usage() {
    echo "usage: brightness.sh <add|sub|set> <amount>"
}

if [ -z "$MODE" ]; then
    echo "specify add|sub|set"

    exit 1
fi

if [ -z "$AMT" ]; then
    echo "specify amount to modify backlight"

    exit 1
fi

if [ "$MODE" = "add" ]; then
    xbacklight -inc ${AMT}
fi

if [ "$MODE" = "set" ]; then
    xbacklight -set ${AMT}
fi

if [ "$MODE" = "sub" ]; then
    CURRENT=$(xbacklight -get)

    RESULT=$(expr $CURRENT - $AMT)

    if (( RESULT < 1 )); then
        xbacklight -set 1
    else
        xbacklight -dec ${AMT}
    fi
fi