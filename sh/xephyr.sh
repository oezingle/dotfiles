#!/bin/sh

Xephyr :4 & sleep 1 ; DISPLAY=:4 awesome -c "$PWD/rc.lua"