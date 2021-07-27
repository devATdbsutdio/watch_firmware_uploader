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

ARDUINO="$(which /usr/local/bin/arduino-cli)"

# IFS=$'\n' CORE_URLS=(read -a $($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE"))
# IFS=$'\n' read -r -d '' -a CORE_URLS < <($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE")

# echo "size of array: ${#CORE_URLS[*]}"

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

# IFS=$'\n' read -r -d '' -a CORES < <($ymal_parse e '.BINARY.CORES.CORE_NAMES[]' "$I_SETTINGS_FILE")

# for CORE in "${CORES[@]}"; do
# 	echo ""
# 	echo -e "> Searching $CORE..."
# 	SEARCH_CMD="$ARDUINO core search $CORE"
# 	if [[ ! "$($SEARCH_CMD)" =~ "No" ]]; then
# 		echo -e " Core found. Installing now ..."
# 		CORE_INSTALL_CMD="$ARDUINO core install $CORE"
# 		sleep 2
# 		$CORE_INSTALL_CMD
# 		core_install_count=$((core_install_count + 1))
# 		echo " "
# 	else
# 		echo -e "${RED} No such Core !${RESET}"
# 		sleep 2
# 	fi
# done
# process_list

IFS=$'\n' read -r -d '' -a LIB_LIST < <($ymal_parse e '.LIBS[]' "$I_SETTINGS_FILE")
lib_install_count=0
LIBINSTALL_CMD=""
for LIB in "${LIB_LIST[@]}"; do
	echo ""
	# echo -e "> Parsing Libraries list from the settings file..."
	if [[ $LIB = *"https:"* ]]; then
		# parse the end of the git link to get lib's name
		LIB_NAME=$(echo "$LIB" | cut -d'/' -f 5)
		LIB_NAME_LEN_WITH_GIT=${#LIB_NAME}
		IDX_OF_DOT=$((LIB_NAME_LEN_WITH_GIT - 4))
		LIB_NAME=${LIB_NAME:0:$IDX_OF_DOT}
		echo -e "  $LIB_NAME src is from a git link"

		echo " "
		echo -e "> Installing $LIB_NAME from git ..."
		LIBINSTALL_CMD="$ARDUINO lib install --git-url $LIB"
		echo "$LIBINSTALL_CMD"
		echo " "
		lib_install_count=$((lib_install_count + 1))
	else
		echo "  $LIB is a pure lib name"
		LIBSEARCH_CMD="$ARDUINO lib search $LIB --names"
		LIBINSTALL_CMD="$ARDUINO lib install $LIB"
		echo -e "> Searching $LIB in Library manager ..."
		LIBSEARCH_CMD="$ARDUINO lib search $LIB --names"
		if [[ "$($LIBSEARCH_CMD)" == *$LIB* ]]; then
			echo -e "  $LIB found in Library Manager!"
			sleep 2
			echo -e "> Installing $LIB from Library Manager ..."
			LIBINSTALL_CMD="$ARDUINO lib install $LIB"
			echo "$LIBINSTALL_CMD"
			echo " "
			lib_install_count=$((lib_install_count + 1))
		else
			echo -e "  $LIB not found in Library Manager!"
			echo " "
			sleep 2
		fi
	fi
done
