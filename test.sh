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

countdown() {
        msg="BACK TO PROMPT IN: "
        clear
        tput cup 10 5
        echo -n "$msg"
        l=${#msg}
        l=$(( l+5 ))
        for i in {2..1}
        do
                tput cup 10 $l
                echo -n "$i"
                sleep 1
        done
}

countdown

UPLOAD_CMD=($HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p $port -P pyupdi -t)

echo " > EXECUTING: ${UPLOAD_CMD[*]}"
