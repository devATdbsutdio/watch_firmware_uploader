#!/bin/bash

I_SETTING_FILE_NAME=installer_settings.yaml
FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
I_SETTINGS_FILE=$SETTINGS_DIR/$I_SETTING_FILE_NAME

CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml
ymal_parse=$HOME/bin/yq #used for parsing settings.yaml file

IFS=$'\n' CORE_URLS=("$($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE")")

for CORE_URL in ${CORE_URLS[*]}; do
	if grep -q "$CORE_URL" "$CONFIG_FILE"; then
		echo -e "$CORE_URL already exists in config file"
	else
		echo -e "$CORE_URL doesn't exist in config file!"
		sleep 2
		echo -e "Adding $CORE_URL to config file"
		sleep 2
		ARDUINO=/home/pi/test/bin/arduino-cli
		ADD_CORE_URL="$ARDUINO config add board_manager.additional_urls $CORE_URL"
		echo "$ADD_CORE_URL"
		echo ""
		$ADD_CORE_URL
	fi
done
