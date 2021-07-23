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
        for i in {30..1}
        do
                tput cup 10 $l
                echo -n "$i"
                sleep 1
        done
}

countdown
