#!/bin/bash

SETTING_FILE_NAME=settings.yaml

# ymal_parse=$("which yq") #used for parsing setting file
ymal_parse=$HOME/bin/yq #used for parsing settings.yaml file

FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
SETTINGS_FILE=$SETTINGS_DIR/$SETTING_FILE_NAME
LAST_PULL_INFO_FILE=$HOME/.last_pull.txt

# ---- color info ---- #
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'
WHOLE_LINE_YELLOW='\x1b[43;30m'
WHOLE_LINE_RESET='\x1b[K\x1b[0m'
HEIGHT=$(tput lines)
# -------------------- #

# ---- Pre-checks ---- #
clear
echo ""
echo -e "${YELLOW}Loading settings ...${RESET}"
sleep 1
if [ -f "$LAST_PULL_INFO_FILE" ]; then
  echo -e "${GREEN}Last pull request info exists!${RESET}"
else
  echo -e "${RED}No \"last pull request\" info found!${RESET}"
fi
sleep 4
if [ -f "$SETTINGS_FILE" ]; then
  echo -e "${GREEN}TARGET SETTINGS EXIST IN: $SETTINGS_FILE${RESET}"
  sleep 5
else
  echo -e "${RED}TARGET SETTINGS file $SETTING_FILE_NAME doesn't seem to exist in: $SETTINGS_DIR/"
  echo -e "QUITTING !${RESET}"
  sleep 5
  exit 1
fi
echo -e "${YELLOW}Applying Settings ...${RESET}"
sleep 1
# -------------------- #

# ---- Assiging arduino-cli parameters from settings file ---- #
ARDUINO=$($ymal_parse e '.BINARY.LOCATION' "$SETTINGS_FILE")
CORE=$("$HOME"/bin/yq e '.MICROCONTROLLER.CORE' "$SETTINGS_FILE")
CHIP=$("$HOME"/bin/yq e '.MICROCONTROLLER.CHIP' "$SETTINGS_FILE")
CLOCK=$("$HOME"/bin/yq e '.MICROCONTROLLER.CLOCK' "$SETTINGS_FILE")
BOD=$("$HOME"/bin/yq e '.MICROCONTROLLER.BOD' "$SETTINGS_FILE")
BODMODE=$("$HOME"/bin/yq e '.MICROCONTROLLER.BODMODE' "$SETTINGS_FILE")
EEPROM_SAVE=$("$HOME"/bin/yq e '.MICROCONTROLLER.EEPROM_SAVE' "$SETTINGS_FILE")
MILLIS=$("$HOME"/bin/yq e '.MICROCONTROLLER.MILLIS' "$SETTINGS_FILE")
RESET_PIN=$("$HOME"/bin/yq e '.MICROCONTROLLER.RESET_PIN' "$SETTINGS_FILE")
STARTUP_TIME=$("$HOME"/bin/yq e '.MICROCONTROLLER.STARTUP_TIME' "$SETTINGS_FILE")
UARTV=$("$HOME"/bin/yq e '.MICROCONTROLLER.UARTV' "$SETTINGS_FILE")
PORT="--"
PROGRAMMER=$("$HOME"/bin/yq e '.MICROCONTROLLER.PROGRAMMER' "$SETTINGS_FILE")
FIRMWARE_DIR=$("$HOME"/bin/yq e '.FIRMWARE.DIR' "$SETTINGS_FILE")

UPLOAD_CMD=("$ARDUINO" compile -b "$CORE":chip="$CHIP",clock="$CLOCK",bodvoltage="$BOD",bodmode="$BODMODE",eesave="$EEPROM_SAVE",millis="$MILLIS",resetpin="$RESET_PIN",startuptime="$STARTUP_TIME",uartvoltage="$UARTV" "$FIRMWARE_DIR" -u -p $PORT -P "$PROGRAMMER" -t)

# ----------------------------------------------------------- #

BANNER="
----------------------
|  FIRMARE UPLOADER  |
----------------------
> CURRENT FIRMWARE: $FIRMWARE_DIR
"

PORT_STAT="PORT: $PORT"
LAST_PULL=$(<"$LAST_PULL_INFO_FILE")
PULL_STAT="LAST PULL: $LAST_PULL"
LAST_BURN="--"
BURN_STAT="FIRMWARE BURN STAT: $LAST_BURN"
BOTT_STAT="$PORT_STAT | $PULL_STAT | $BURN_STAT"

set_window() {
  # Create a virtual window that is two lines smaller at the bottom.
  tput csr 0 $((HEIGHT - 2))
}

show_header_and_footer() {
  clear
  echo -e "${YELLOW}$BANNER${RESET}" && echo ""
  echo -e "${YELLOW} PRESS [ P ] THEN [ ENTER ] - LATEST FIRMWARE.${RESET}"
  echo -e "${YELLOW} PRESS [ S ] THEN [ ENTER ] - UPLOAD PORT [ YOUR DEVICE SHOULD BE C ONNECTED FOR THIS STEP ].${RESET}"
  echo -e "${YELLOW} PRESS [ U ] THEN [ ENTER ] - FIRMWARE [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ].${RESET}" && echo " "

  # Move cursor to last line in your screen
  tput cup "$HEIGHT" 0

  PORT_STAT="PORT: $PORT"
  PULL_STAT="LAST PULL: $LAST_PULL"
  BURN_STAT="FIRMWARE BURN STAT: $LAST_BURN"
  BOTT_STAT="$PORT_STAT | $PULL_STAT | $BURN_STAT"

  echo -e "${WHOLE_LINE_YELLOW}$BOTT_STAT${WHOLE_LINE_RESET}"

  # Move cursor to home position, back in virtual window
  tput cup 10 0
}

echo "Staring now ... "

while true; do
  clear
  set_window
  show_header_and_footer

  read -r -p "  > " input
  case $input in
  [pP])
    LAST_PULL="pulling now..."
    show_header_and_footer

    echo "EXECUTING:"
    echo "$FIRMWARE_REPO_DIR && git pull"
    cd "$FIRMWARE_REPO_DIR" && git pull
    cd "$HOME" || return
    sleep 2
    # get current time stamp
    current_date_time="$(date +"%Y-%m-%d %T")"
    # show curr time stamp
    LAST_PULL="$current_date_time"
    # save curr time stamp
    echo "$LAST_PULL" >"$LAST_PULL_INFO_FILE"
    sleep 2
    clear
    ;;
  [sS])
    show_header_and_footer

    IFS=$'\n' ports=($(find /dev/tty*))
    select port in "${ports[@]}"; do
      PORT=$port
      PORT_STAT="PORT: $PORT"
      # update the upload command with the port
      UPLOAD_CMD[7]=$port
      break
    done
    clear
    ;;
  [uU])
    LAST_BURN="Uploading now..."
    show_header_and_footer

    echo "EXECUTING:"
    echo "${UPLOAD_CMD[@]}"

    # sleep 30

    "${UPLOAD_CMD[@]}"

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
