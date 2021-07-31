#!/bin/bash

SETTING_FILE_NAME=programmer_settings.yaml

ymal_parse="$(/usr/bin/which yq)"
FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
SETTINGS_FILE=$SETTINGS_DIR/$SETTING_FILE_NAME
LAST_PULL_INFO_FILE=$HOME/.last_pull.txt

# ---- color info ---- #
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'
# WHOLE_LINE_YELLOW='\x1b[43;30m'
# WHOLE_LINE_RESET='\x1b[K\x1b[0m'
# -------------------- #

# ---- Pre-checks ---- #
LAST_PULL=0
# PULL_STAT="LAST PULL: $LAST_PULL"

clear
echo ""
echo -e "${YELLOW}Loading settings ...${RESET}"
# sleep 1

if [ -f "$LAST_PULL_INFO_FILE" ]; then
  echo -e "${GREEN}Last pull request info exists!${RESET}"
  LAST_PULL=$(<"$LAST_PULL_INFO_FILE")
else
  echo -e "${RED}No \"last pull request\" info found!${RESET}"
  LAST_PULL=0
fi

# PULL_STAT="LAST PULL: $LAST_PULL"
# sleep 1

if [ -f "$SETTINGS_FILE" ]; then
  echo -e "${GREEN}TARGET SETTINGS EXIST IN: $SETTINGS_FILE${RESET}"
  sleep 1
else
  echo -e "${RED}TARGET SETTINGS file $SETTING_FILE_NAME doesn't seem to exist in: $SETTINGS_DIR/"
  echo -e "QUITTING !${RESET}"
  sleep 3
  exit 1
fi
echo -e "${YELLOW}Applying Settings ...${RESET}"
sleep 3

# -------------------- #

# ---- Assiging arduino-cli parameters from settings file ---- #
ARDUINO=$($ymal_parse e '.BINARY.LOCATION' "$SETTINGS_FILE")

TARGET_NAME="$($ymal_parse e '.MICROCONTROLLER.TARGET.NAME' "$SETTINGS_FILE")"

CORE=$($ymal_parse e '.MICROCONTROLLER.TARGET.CORE' "$SETTINGS_FILE")

CHIP=$($ymal_parse e '.MICROCONTROLLER.FUSES.CHIP' "$SETTINGS_FILE")
CLOCK=$($ymal_parse e '.MICROCONTROLLER.FUSES.CLOCK' "$SETTINGS_FILE")
BOD=$($ymal_parse e '.MICROCONTROLLER.FUSES.BOD' "$SETTINGS_FILE")
BODMODE=$($ymal_parse e '.MICROCONTROLLER.FUSES.BODMODE' "$SETTINGS_FILE")
EEPROM_SAVE=$($ymal_parse e '.MICROCONTROLLER.FUSES.EEPROM_SAVE' "$SETTINGS_FILE")
MILLIS=$($ymal_parse e '.MICROCONTROLLER.FUSES.MILLIS' "$SETTINGS_FILE")
RESET_PIN=$($ymal_parse e '.MICROCONTROLLER.FUSES.RESET_PIN' "$SETTINGS_FILE")
STARTUP_TIME=$($ymal_parse e '.MICROCONTROLLER.FUSES.STARTUP_TIME' "$SETTINGS_FILE")
UARTV=$($ymal_parse e '.MICROCONTROLLER.FUSES.UARTV' "$SETTINGS_FILE")
PORT="[x]"
LAST_BURN="[x]"
PROGRAMMER=$($ymal_parse e '.MICROCONTROLLER.FUSES.PROGRAMMER' "$SETTINGS_FILE")

FIRMWARE_DIR=$($ymal_parse e '.FIRMWARE.SKETCHES[0]' "$SETTINGS_FILE")
FIRM_WARE_NAME="$(basename $FIRMWARE_DIR)"
UPLOAD_CMD=("$ARDUINO" compile -b "$CORE":chip="$CHIP",clock="$CLOCK",bodvoltage="$BOD",bodmode="$BODMODE",eesave="$EEPROM_SAVE",millis="$MILLIS",resetpin="$RESET_PIN",startuptime="$STARTUP_TIME",uartvoltage="$UARTV" "$FIRMWARE_DIR" -u -p $PORT -P "$PROGRAMMER" -t)

# ----------------------------------------------------------- #

FUSE_SETTING_UI="$($ymal_parse e '.MICROCONTROLLER.FUSES[]' "$SETTINGS_FILE")"

BANNER="

  ${YELLOW}ARDUINO:${RESET} $ARDUINO
  ${YELLOW}SKETCH:${RESET} $FIRM_WARE_NAME
  ${YELLOW}PULL STAT:${RESET} $LAST_PULL

  ${YELLOW}TARGET:${RESET} $TARGET_NAME
  ${YELLOW}UPLOAD PORT:${RESET} $PORT

  ${YELLOW}UPLOADED:${RESET} $LAST_BURN
"

# BURN_STAT="FIRMWARE BURN STAT: $LAST_BURN"
# BOTT_STAT="$PORT_STAT  $PULL_STAT  $BURN_STAT"

show_header() {
  PORT=$PORT
  LAST_PULL=$LAST_PULL
  LAST_BURN=$LAST_BURN

  clear

  echo -e "$BANNER" && echo ""
  echo -e "${YELLOW} [S] = SELECT UPLOAD PORT${RESET}"
  echo -e "${YELLOW} [P] = GET LATEST FIRMWARE${RESET}"
  echo -e "${YELLOW} [U] = UPLOAD FIRMWARE${RESET}" && echo " "
}

echo "Staring now ... "

while true; do
  clear

  show_header

  read -r -p "  > " input
  case $input in
  [pP])
    LAST_PULL="[pulling..]"
    show_header

    echo "EXECUTING:"
    echo " cd $FIRMWARE_REPO_DIR && git pull "
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
    show_header

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
    LAST_BURN="->"
    show_header

    echo "EXECUTING:"
    echo "${UPLOAD_CMD[@]}"

    # sleep 30

    "${UPLOAD_CMD[@]}"

    # burn_date_time="$(date +"%Y-%m-%d %T")"
    LAST_BURN="[DONE]"
    show_header
    sleep 2
    clear
    ;;
  *)
    # -- [TBD] show invalid input status
    show_header
    sleep 2
    clear
    ;;
  esac
done
