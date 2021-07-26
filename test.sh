#!/bin/bash

I_SETTING_FILE_NAME=installer_settings.yaml
FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
I_SETTINGS_FILE=$SETTINGS_DIR/$I_SETTING_FILE_NAME

echo "$I_SETTINGS_FILE"

CONFIG_FILE="$HOME"/.arduino15/arduino-cli.yaml
echo "$CONFIG_FILE"
ymal_parse="$(/usr/bin/which yq)" #used for parsing settings.yaml file
echo "$ymal_parse"

ARDUINO=/home/pi/test/bin/arduino-cli

# IFS=$'\n' CORE_URLS=(read -a $($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE"))
IFS=$'\n' read -r -d '' -a CORE_URLS < <($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE")

echo "size of array: ${#CORE_URLS[*]}"

# cd $HOME

# for CORE_URL in "${CORE_URLS[@]}"; do
# 	if grep -q "$CORE_URL" "$CONFIG_FILE"; then
# 		echo -e "$CORE_URL already exists in config file"
# 	else
# 		echo -e "$CORE_URL doesn't exist in config file!"
# 		sleep 2
# 		echo -e "Adding $CORE_URL to config file"
# 		sleep 2
# 		ARDUINO=/home/pi/test/bin/arduino-cli
# 		ADD_CORE_URL="$ARDUINO config add board_manager.additional_urls $CORE_URL"
# 		echo "$ADD_CORE_URL"
# 		echo ""
# 		$ADD_CORE_URL
# 	fi
# done

IFS=$'\n' read -r -d '' -a CORES < <($ymal_parse e '.BINARY.CORES.CORE_NAMES[]' "$I_SETTINGS_FILE")

for CORE in "${CORES[@]}"; do
	echo ""
	echo -e "> Searching $CORE..."
	SEARCH_CMD="$ARDUINO core search $CORE"
	if [[ ! "$($SEARCH_CMD)" =~ "No" ]]; then
		echo -e " Core found. Installing now ..."
		CORE_INSTALL_CMD="$ARDUINO core install $CORE"
		sleep 2
		$CORE_INSTALL_CMD
		core_install_count=$((core_install_count + 1))
		echo " "
	else
		echo -e "${RED} No such Core !${RESET}"
		sleep 2
	fi
done
process_list
