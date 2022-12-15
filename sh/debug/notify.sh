#!/bin/bash

for i in {1..25}; do
    notify-send -a "example notification" "test ${i}"
done