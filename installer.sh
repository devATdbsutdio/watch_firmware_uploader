#!/bin/bash

SETTING_FILE_NAME=settings.yaml
# ymal_parse=$("which yq") #used for parsing setting file
ymal_parse=$HOME/bin/yq #used for parsing settings.yaml file

FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
SETTINGS_FILE=$SETTINGS_DIR/$SETTING_FILE_NAME

BIN_BASE_DIR=$($ymal_parse e '.BINARY.BASE' "$SETTINGS_FILE")
CORE_URL=http://drazzy.com/package_drazzy.com_index.json
ARDUINO=""
CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml
CORE=megaTinyCore
CORE_COMB=megaTinyCore:megaavr
LIB_LIST=(TinyMegaI2C RV8803Tiny)
# TWOWIRELIB=TinyMegaI2C
# RTCLIB=RV8803Tiny

clear
sleep 1

# ---- Install arduino-cli ---- #
sleep 1
echo "Going to base directory: $BIN_BASE_DIR"
cd "$BIN_BASE_DIR" || return
sleep 2
echo "Making \"bin\" directory..."
mkdir bin
sleep 2
echo "Going to bin directory: $BIN_BASE_DIR/bin ..."
cd "$BIN_BASE_DIR"/bin || return
sleep 2
echo "Downloading arduino-cli..."
sleep 2
wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARMv7.tar.gz
echo "Download finished!"
sleep 2
echo "Unzipping..."
tar -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
rm arduino-cli_latest_Linux_ARMv7.tar.gz
rm LICENSE.txt
echo "arduino-cli installed in $BIN_BASE_DIR/bin/arduino-cli"
ARDUINO=$BIN_BASE_DIR/bin/arduino-cli
# ** Entry cli's location in settings.yaml
$ymal_parse e ".BINARY.LOCATION |= \"$ARDUINO\"" "$SETTINGS_FILE"

sleep 4
# go back to the home directory
cd "$HOME" || return

# ---- Create Arduino-cli init file [if it doesn't exist]---- #
[ ! -f "$CONFIG_FILE" ] && "$ARDUINO" config init && echo "There is Config file now!"

sleep 2

# ---- Add in board's manager additonal urls for MegaTinyCore ---- #
ADD_CORE_URL="$ARDUINO config add board_manager.additional_urls $CORE_URL"

if grep -q "$CORE_URL" "$CONFIG_FILE"; then
  echo "$CORE_URL already exists in config file"
  sleep 2
else
  echo "$CORE_URL doesn't exist in config file!"
  sleep 2
  echo "Adding $CORE_URL to config file"
  sleep 2
  $ADD_CORE_URL
fi

# ---- Install the megaTinyCore ---- #
SEARCH_CMD="$ARDUINO core search $CORE"
CORE_INSTALL_CMD="$ARDUINO core install $CORE_COMB"

echo "Searching $CORE..."

if [[ ! "$($SEARCH_CMD)" =~ "No" ]]; then
  echo "Core found. Installing now ..."
  sleep 2
  $CORE_INSTALL_CMD
elif [[ "$($SEARCH_CMD)" =~ "No" ]]; then
  echo "No such Core !"
  sleep 2
fi

# ---- Install the necessary libraries  ---- #
LIBSEARCH_CMD="$ARDUINO lib search"
LIBINSTALL_CMD="$ARDUINO lib install"

for LIB in "${LIB_LIST[@]}"; do
  echo "Searching $LIB in Library manager..."
  if [[ "$($LIBSEARCH_CMD "$LIB" --names)" == *$LIB* ]]; then
    echo "Library found in Library Manager Repo!)"
    sleep 2
    $LIBINSTALL_CMD "$LIB"
  else
    echo "$LIB library not found!"
  fi
done

# echo "Searching $TWOWIRELIB in Library manager..."
# if [[ "$($LIBSEARCH_CMD $TWOWIRELIB --names)" == *$TWOWIRELIB* ]]; then
#   echo "library found in Library Manager Repo:)"
#   echo "Installing $TWOWIRELIB Library..."
#   $LIBINSTALL_CMD $TWOWIRELIB
# else
#   echo "$TWOWIRELIB library not found!"
# fi

# echo "Searching $RTCLIB in Library manager..."
# if [[ "$($LIBSEARCH_CMD $RTCLIB --names)" == *$RTCLIB* ]]; then
#   echo "library found in Library Manager Repo :)"
#   echo "Installing $RTCLIB Library..."
#   $LIBINSTALL_CMD $RTCLIB
# else
#   echo "$RTCLIB library not found!"
# fi

# ---- git clone the firmware source code ---- #
# cd "$HOME" || return
# git clone https://github.com/dattasaurabh82/clock_firmware_production.git
