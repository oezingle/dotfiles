#!/bin/sh

# prints memory usage as a percentage every 0.1s

watch -n 0.1 ps -o %mem $(pidof awesome)