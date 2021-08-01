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
# -------------------- #

# ---- Pre-checks ---- #
LAST_PULL=0

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
# [TBD] it's hardcoded now. Make a selector later
FIRMWARE_DIR=$($ymal_parse e '.FIRMWARE.SKETCHES[0]' "$SETTINGS_FILE")
FIRM_WARE_NAME="$(basename "$FIRMWARE_DIR")"

FULL_FQBN_WITH_FUSES="$CORE":chip="$CHIP",clock="$CLOCK",bodvoltage="$BOD",bodmode="$BODMODE",eesave="$EEPROM_SAVE",millis="$MILLIS",resetpin="$RESET_PIN",startuptime="$STARTUP_TIME",uartvoltage="$UARTV"
UPLOAD_CMD=("$ARDUINO" compile -b "$FULL_FQBN_WITH_FUSES" "$FIRMWARE_DIR" -u -p "$PORT" -P "$PROGRAMMER" -t)
# ----------------------------------------------------------- #

# HEIGHT=$(tput lines)
# set_window() {
#   # Create a virtual window that is 14 lines smaller at the bottom.
#   tput csr 0 $((HEIGHT - 14))
# }

banner() {
  echo -e "${YELLOW}---------------------------------------------${RESET}"
  echo -e "${YELLOW}FIRMWARE:${RESET}\t$FIRM_WARE_NAME"
  echo -e "${YELLOW}PULL STAT:${RESET}\t$LAST_PULL"
  echo -e "${YELLOW}TARGET UC:${RESET}\t$TARGET_NAME"
  echo -e "${YELLOW}UPLOAD PORT:${RESET}\t${GREEN}$PORT${RESET}"
  echo -e "${YELLOW}TOTAL UPLOADS:${RESET}\t${GREEN}$LAST_BURN${RESET}"
  echo -e "${YELLOW}---------------------------------------------${RESET}"
}

show_header() {
  clear
  echo ""
  banner
  echo ""
  echo -e "${YELLOW}[S]${RESET} SELECT \"UPLOADING PORT\""
  echo -e "${YELLOW}[P]${RESET} GET THE LATEST FIRMWARE"
  echo -e "${YELLOW}[U]${RESET} UPLOAD THE FIRMWARE" && echo ""
}

echo "Staring now ... "

while true; do
  # get_size
  clear
  # Save cursor position
  tput sc
  # Add a new line
  tput il 1
  # Change scroll region to exclude the first 14 lines
  tput csr 0 14
  # Move cursor to top line
  tput cup 0 0
  # Clear to the end of the line
  tput el

  show_header

  # Restore cursor position
  tput rc

  read -r -p "  > " input
  case $input in
  [pP])
    LAST_PULL="${GREEN}[pulling..]${RESET}"
    show_header
    cd "$FIRMWARE_DIR" && git checkout main && git up
    cd "$HOME" || return
    sleep 2
    # get current time stamp
    current_date_time="$(date +"%Y-%m-%d %T")"
    # show curr time stamp
    LAST_PULL="$current_date_time"
    # save curr time stamp
    echo "$LAST_PULL" >"$LAST_PULL_INFO_FILE"
    # sleep 5
    clear
    ;;
  [sS])
    show_header
    IFS=$'\n' read -r -d '' -a ports < <(find /dev/ttyUSB*)
    select port in "${ports[@]}"; do
      PORT=$port
      # update the upload command with the port
      UPLOAD_CMD[7]=$port
      break
    done
    clear
    ;;
  [uU])
    LAST_BURN="Uploading..."
    show_header

    echo "EXECUTING:"
    echo "${UPLOAD_CMD[@]}"

    "${UPLOAD_CMD[@]}"

    sleep 2

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

# ---------------
# get_size() {
#   set -- $(stty size)
#   LINES=$1
#   COLUMNS=$2
# }
# reset_scrolling() {
#   get_size
#   clear
#   tput csr 0 $((LINES - 1))
# }

# # Reset the scrolling region
# printf %s 'Press ENTER to reset scrolling (will clear screen)'
# read a_line
# reset_scrolling

# ec=$?
# exit "$ec"
