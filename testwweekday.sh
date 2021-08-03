#!/bin/bash

h=$(date +"%H")
m=$(date +"%M")
s=$(date +"%S")
w=$(date +"%w")
d=$(date +"%d")
m=$(date +"%m")
y=$(date +"%Y")

time="$h:$m:$s:$w:$d:$m:$y"
# echo "$time"

SERIAL_PORT=/dev/tty.usbserial-A10KHTRO
echo -e "$time\n" >$SERIAL_PORT
# /dev/tty.usbserial-A10KHTRO
