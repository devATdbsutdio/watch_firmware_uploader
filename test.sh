#!/bin/bash


#TWOWIRELIB=TinyMegaI2C
#RTCLIB=RV8803Tiny
#LIBSEARCH_CMD="arduino-cli lib search"

#$LIBSEARCH_CMD $TWOWIRELIB --names

#if [[ "$($LIBSEARCH_CMD $TWOWIRELIB --names)" == *$TWOWIRELIB* ]]; then
#  echo "library found"
#else
#  echo "library not found"
#fi

#PS3="Enter a number: "

#select character in Sheldon Leonard Penny Howard Raj
#do
#    echo "Selected character: $character"
#    echo "Selected number: $REPLY"
#done

FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock

UPLOAD_CMD="$HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p /dev/ttyUSB0 -P pyupdi -t"
