#!/bin/bash

# prints the name of the script
#echo $0

# prints the absolute path of the script 
FULL_PATH=$(realpath "$0")

# prints the dir of the script
SETTINGS_DIR=$(dirname "$FULL_PATH")
SETTINGS_FILE=$SETTINGS_DIR/settings.yaml


BIN=$("$HOME"/bin/yq e '.BINARY.LOCATION' "$SETTINGS_FILE")
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
PORT="/dev/ttyUSB0"
PROGRAMMER=$("$HOME"/bin/yq e '.MICROCONTROLLER.PROGRAMMER' "$SETTINGS_FILE")
FIRMWARE_DIR=$("$HOME"/bin/yq e '.FIRMWARE.DIR' "$SETTINGS_FILE")

UPLOAD_CMD=("$BIN" compile -a "$CORE":chip="$CHIP",clock="$CLOCK",bodvoltage="$BOD",bodmode="$BODMODE",eesave="$EEPROM_SAVE",millis="$MILLIS",resetpin="$RESET_PIN",startuptime="$STARTUP_TIME",uartvoltage="$UARTV" "$FIRMWARE_DIR" -u -p "$PORT" -P "$PROGRAMMER" -t) 


${UPLOAD_CMD[@]}
