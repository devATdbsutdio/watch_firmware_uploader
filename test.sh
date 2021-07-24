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

#countdown() {
#        msg="BACK TO PROMPT IN: "
#        clear
#        tput cup 10 5
#        echo -n "$msg"
#        l=${#msg}
#        l=$(( l+5 ))
#        for i in {2..1}
#        do
#                tput cup 10 $l
#                echo -n "$i"
#                sleep 1
#        done
#}

#countdown

#UPLOAD_CMD=($HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p $port -P pyupdi -t)


WHOLE_LINE_GREEN='\x1b[42;32m'
WHOLE_LINE_RESET='\x1b[K\x1b[0m'

HEIGHT=$(tput lines)

set_window (){
  # Create a virtual window that is two lines smaller at the bottom.
  tput csr 0 $(($HEIGHT-2))
}

footer_status () {
  # Move cursor to last line in your screen
  tput cup $HEIGHT 0;
  
  echo -e "${WHOLE_LINE_GREEN}TEST STATUS STRING${WHOLE_LINE_RESET}"
  
  # Move cursor to home position, back in virtual window
  tput cup 0 0
}

while true
do
 clear
 set_window
 footer_status

 read -r -p "  > " input
 case $input in
   [pP])
 footer_status
 clear
 ;;
  *)
 footer_status
 clear
 ;;
 esac
done
