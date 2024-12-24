#!/bin/sh

# Starts Awesome with this configuration as a real session

# Get to the right place
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
cd ../

awesome -c ./rc.lua > ./log.txt 2>&1