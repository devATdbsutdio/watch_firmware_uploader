#!/bin/bash


FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
SETTINGS_FILE=$SETTINGS_DIR/settings.yaml


FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock
last_pull_info_file=$HOME/last_pull.txt

BIN=$("$HOME"/bin/yq e '.BINARY.LOCATION' "$SETTINGS_FILE")
CORE=$("$HOME"/bin/yq e '.MICROCONTROLLER.CORE' "$SETTINGS_FILE")
CHIP=$("$HOME"/bin/yq e '.MICROCONTROLLER.CHIP' "$SETTINGS_FILE")
CLOCK=$("$HOME"/bin/yq e '.MICROCONTROLLER.CLOCK' "$SETTINGS_FILE")
BOD=$("$HOME"/bin/yq e '.MICROCONTROLLER.BOD' "$SETTINGS_FILE")
BODMODE=$("$HOME"/bin/yq e '.MICROCONTROLLER.BODMODE' "$SETTINGS_FILE")
EPROM_SAVE=$("$HOME"/bin/yq e '.MICROCONTROLLER.EEPROM_SAVE' "$SETTINGS_FILE")
MILLIS=$("$HOME"/bin/yq e '.MICROCONTROLLER.MILLIS' "$SETTINGS_FILE")
RESET_PIN=$("$HOME"/bin/yq e '.MICROCONTROLLER.RESET_PIN' "$SETTINGS_FILE")
STARTUP_TIME=$("$HOME"/bin/yq e '.MICROCONTROLLER.STARTUP_TIME' "$SETTINGS_FILE")
UARTV=$("$HOME"/bin/yq e '.MICROCONTROLLER.UARTV' "$SETTINGS_FILE")
PORT="--"
PROGRAMMER=$("$HOME"/bin/yq e '.MICROCONTROLLER.PROGRAMMER' "$SETTINGS_FILE")
FIRMWARE_DIR=$("$HOME"/bin/yq e '.FIRMWARE.DIR' "$SETTINGS_FILE")


UPLOAD_CMD=("$BIN" compile -b "$CORE":chip="$CHIP",clock="$CLOCK",bodvoltage="$BOD",bodmode="$BODMODE",eesave="$EEPROM_SAVE",millis="$MILLIS",resetpin="$RESET_PIN",startuptime="$STARTUP_TIME",uartvoltage="$UARTV" "$FIRMWARE_DIR" -u -p "$PORT" -P "$PROGRAMMER" -t)

echo "${UPLOAD_CMD[@]}"


#SER_PORT_REGEX='/dev/ttyA\|/dev/ttyp\|/dev/ttyU\|/dev/tty.u'




GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'
WHOLE_LINE_YELLOW='\x1b[43;30m'
WHOLE_LINE_RESET='\x1b[K\x1b[0m'

HEIGHT=$(tput lines)

set_window (){
    # Create a virtual window that is two lines smaller at the bottom.
    tput csr 0 $(( HEIGHT-2 ))
}


PORT_STAT="PORT: $PORT"
LAST_PULL=$(<"$last_pull_info_file")
PULL_STAT="LAST PULL: $LAST_PULL"
LAST_BURN=""
BURN_STAT="FIRMWARE BURN STAT: $LAST_BURN"
BOTT_STAT="$PORT_STAT | $PULL_STAT | $BURN_STAT"

footer_status () {
    # Move cursor to last line in your screen
    tput cup "$HEIGHT" 0;

    BOTT_STAT="$PORT_STAT | $PULL_STAT | $BURN_STAT"
    echo -e "${WHOLE_LINE_YELLOW}$BOTT_STAT${WHOLE_LINE_RESET}"
    
    # sleep 5

    # Move cursor to home position, back in virtual window
    tput cup 17 0
}


BANNER="
   __ _                                       
  / _(_)_ __ _ __ _____      ____ _ _ __ ___  
 | |_| | '__| '_ \` _ \ \ /\ / / _\` | '__/ _ \ 
 |  _| | |  | | | | | \ V  V / (_| | | |  __/ 
 |_| |_|_|  |_| |_| |_|\_/\_/ \__,_|_|  \___| 
  _   _ _ __ | | ___   __ _  __| | ___ _ __   
 | | | | '_ \| |/ _ \ / _\` |/ _\` |/ _ \ '__|  
 | |_| | |_) | | (_) | (_| | (_| |  __/ |     
  \__,_| .__/|_|\___/ \__,_|\__,_|\___|_|     
       |_|
"

show_header_and_footer (){
  clear 

  echo -e "${YELLOW}$BANNER${RESET}" && echo " " && echo " "
  echo -e "${YELLOW} PRESS [ P ] THEN [ ENTER ] -> GET LATEST FIRMWARE."
  echo -e "${YELLOW} PRESS [ S ] THEN [ ENTER ] -> SELECT UPLOAD PORT [ YOUR DEVICE SHOULD BE C ONNECTED FOR THIS STEP ]."
  echo -e "${YELLOW} PRESS [ U ] THEN [ ENTER ] -> UPLOAD FIRMWARE [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ].${RESET}" && echo " "

  footer_status
}


while true
do
 clear
 set_window
 show_header_and_footer

 read -r -p "  > " input
 case $input in
   [pP])
 LAST_PULL="pulling now..."
 show_header_and_footer

 echo ""$FIRMWARE_REPO_DIR" && git pull"
 cd "$FIRMWARE_REPO_DIR" && git pull 
 cd ... || return
 sleep 2 
 # get current time stamp
 current_date_time="$(date +"%Y-%m-%d %T")"
 # show curr time stamp
 LAST_PULL="$current_date_time"
 # save curr time stamp
 echo "$LAST_PULL" > "$last_pull_info_file"
 sleep 5
 clear
 ;;
  [sS])
 show_header_and_footer

 IFS=$'\n' ports=( $(find /dev/tty*) )
 select port in "${ports[@]}"; do
   PORT="$port"
   PORT_STAT="PORT: $PORT" ; break
 done
 clear
 ;;
   [uU])
 LAST_BURN="Uploading now..."
 show_header_and_footer
 
 ${UPLOAD_CMD[@]}
 cd ... || return
 
 burn_date_time="$(date +"%Y-%m-%d %T")"
 LAST_BURN="Last burnt at $burn_date_time"
 show_header_and_footer
 sleep 2
 clear 
 ;;
  *)
 # -- [TBD] show invalid input status
 show_header_and_footer
 sleep 2
 clear
 ;;
 esac
done 
