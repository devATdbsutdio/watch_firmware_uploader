#!/bin/bash

# ---- color info ---- #
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'
# -------------------- #

settings_found_loaded=false
cli_installed=false
cli_init_file_created=false
cores_installed=false
libs_installed=false

process_list() {
  while true; do
    clear
    echo -e "${RESET}PROCESS STATUS:${RESET}"
    if [ $settings_found_loaded = true ]; then
      echo -e "${GREEN} [1] Settings File Located and Loaded${RESET}"
    else
      echo -e "${RED} [1] settings.yaml located and Loaded${RESET}"
    fi

    if [ $cli_installed = true ]; then
      echo -e "${GREEN} [2] arduino-cli is installed${RESET}"
    else
      echo -e "${RED} [2] arduino-cli is installed${RESET}"
    fi

    if [ $cli_init_file_created = true ]; then
      echo -e "${GREEN} [2] cli init file created${RESET}"
    else
      echo -e "${RED} [2] cli init file created${RESET}"
    fi

    if [ $cores_installed = true ]; then
      echo -e "${GREEN} [3] Listed cores are installed${RESET}"
    else
      echo -e "${RED} [3] Listed cores are installed${RESET}"
    fi

    if [ $libs_installed = true ]; then
      echo -e "${GREEN}[ 4] Listed libs are installed${RESET}"
    else
      echo -e "${RED} [4] Listed libs are installed${RESET}"
    fi
    # TBD clone repository
    # sleep 10
    # clear

    echo ""
    echo -e "${YELLOW}  Proceed to next step? [Y/n] ${RESET}"
    read -r -p "  > " input
    case $input in
    [yY])
      break
      ;;
    [nN])
      echo "QUITTING..."
      sleep 2
      exit 1
      ;;
    *)
      echo "Invalid input"
      ;;
    esac
  done
  clear
}

# ------- values top be prased from settings file ------- #
CLI_DOWNLOAD_LINK=""
BIN_BASE_DIR=""
CORE_URLS=""
ARDUINO=""
CONFIG_FILE=""
CORE=megaTinyCore
CORE_COMB=megaTinyCore:megaavr
LIB_LIST=(TinyMegaI2C RV8803Tiny)

SETTING_FILE_NAME=settings.yaml
# ymal_parse=$("which yq") #used for parsing setting file
#
ymal_parse=$HOME/bin/yq #used for parsing settings.yaml file

FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")
SETTINGS_FILE=$SETTINGS_DIR/$SETTING_FILE_NAME

# Show the list and task to do
clear
process_list

# ---- Pre-checks ---- #
clear
sleep 1
echo ""
echo -e "${YELLOW} Loading settings ...${RESET}"
sleep 4
if [ -f "$SETTINGS_FILE" ]; then
  echo -e "${GREEN}  TARGET SETTINGS EXIST IN: $SETTINGS_FILE${RESET}"

  CLI_DOWNLOAD_LINK=$($ymal_parse e '.BINARY.LINK' "$SETTINGS_FILE")
  BIN_BASE_DIR=$($ymal_parse e '.BINARY.BASE' "$SETTINGS_FILE")
  CORE_URLS=$($ymal_parse e '.BINARY.CORES.LINK[]' "$SETTINGS_FILE")
  # CORE_URLS=(http://drazzy.com/package_drazzy.com_index.json)
  ARDUINO=""
  CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml

  CORE=megaTinyCore
  CORE_COMB=megaTinyCore:megaavr
  LIB_LIST=(TinyMegaI2C RV8803Tiny)

  sleep 3
  # Show the updated list and task to do
  settings_found_loaded=true
  process_list
else
  echo -e "${RED}TARGET SETTINGS file $SETTING_FILE_NAME doesn't seem to exist in: $SETTINGS_DIR/${RESET}"
  # Show the updated list and task to do
  settings_found_loaded=false
  process_list
  echo -e "${RED} QUITTING in 5 sec !${RESET}"
  sleep 5
  exit 1
fi

# -------------------- #
CLI_DOWNLOAD_LINK=$($ymal_parse e '.BINARY.LINK' "$SETTINGS_FILE")
BIN_BASE_DIR=$($ymal_parse e '.BINARY.BASE' "$SETTINGS_FILE")
CORE_URL=http://drazzy.com/package_drazzy.com_index.json
ARDUINO=""
CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml

CORE=megaTinyCore
CORE_COMB=megaTinyCore:megaavr
LIB_LIST=(TinyMegaI2C RV8803Tiny)

# ---- Install arduino-cli ---- #
# sleep 2
# echo -e "${YELLOW}> Installing arduino-cli in target base directory:${RESET} $BIN_BASE_DIR"
# echo ""
# sleep 2
# echo -e "${YELLOW}> Entering <base>/bin Directory:${RESET} cd $BIN_BASE_DIR/bin"
# sleep 2
# mkdir -p -- "$BIN_BASE_DIR"/bin
# cd "$BIN_BASE_DIR"/bin || exit
# echo -e "${GREEN}  IN $BIN_BASE_DIR/bin now${RESET}"
# sleep 2
# echo ""
# echo -e "${YELLOW}> Downloading arduino-cli...${RESET}"
# echo ""
# sleep 2
# wget "$CLI_DOWNLOAD_LINK"
# echo -e "${GREEN}  Download finished!${RESET}"
# sleep 2
# echo ""
# echo -e "${YELLOW}> Unzipping...${RESET}"
# tar -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
# rm arduino-cli_latest_Linux_ARMv7.tar.gz && rm LICENSE.txt
# echo ""
# echo -e "${GREEN}  arduino-cli installed in:${RESET} $BIN_BASE_DIR/bin/arduino-cli"
# ARDUINO=$BIN_BASE_DIR/bin/arduino-cli
# # ** Update cli's location in settings.yaml
# echo -e "${GREEN}  Updated setting.yaml with arduino-cli's location${RESET}"
# echo "" && echo ""
# echo "---------------------------"
# $ymal_parse e ".BINARY.LOCATION |= \"$ARDUINO\"" "$SETTINGS_FILE"
# echo "---------------------------"
# sleep 5
# # go back to the home directory
# cd "$HOME" || return

cli_installed=true
process_list

# ---- Create Arduino-cli init file [if it doesn't exist]---- #
# echo -e "${YELLOW} Looking for arduino-cli config file...${RESET}"
# if [ ! -f "$CONFIG_FILE" ]; then
#   echo -e "${RED}  It doesn't exist!${RESET}"
#   sleep 2
#   echo -e "${YELLOW}  Creating now..${RESET}"
#   echo ""
#   "$ARDUINO" config init
#   sleep 2
#   echo ""
#   echo "---------------------------"
#   "$ARDUINO" config dump
#   echo "---------------------------"
# else
#   echo -e "${GREEN}  It exists!${RESET}"
#   sleep 2
#   echo ""
#   echo "---------------------------"
#   "$ARDUINO" config dump
#   echo "---------------------------"
# fi
# sleep 2

cli_init_file_created=true
process_list

# ---- Add in board's manager additonal urls for MegaTinyCore ---- #
for url in "${CORE_URLS[@]}"; do
  echo "$url"
done

# ADD_CORE_URL="$ARDUINO config add board_manager.additional_urls $CORE_URL"

# if grep -q "$CORE_URL" "$CONFIG_FILE"; then
#   echo "$CORE_URL already exists in config file"
#   sleep 2
# else
#   echo "$CORE_URL doesn't exist in config file!"
#   sleep 2
#   echo "Adding $CORE_URL to config file"
#   sleep 2
#   $ADD_CORE_URL
# fi

# # ---- Install the megaTinyCore ---- #
# SEARCH_CMD="$ARDUINO core search $CORE"
# CORE_INSTALL_CMD="$ARDUINO core install $CORE_COMB"

# echo ""
# echo "Searching $CORE..."

# if [[ ! "$($SEARCH_CMD)" =~ "No" ]]; then
#   echo "Core found. Installing now ..."
#   sleep 2
#   $CORE_INSTALL_CMD
#   echo ""
# elif [[ "$($SEARCH_CMD)" =~ "No" ]]; then
#   echo "No such Core !"
#   echo ""
#   sleep 2
# fi

# # ---- Install the necessary libraries  ---- #
# LIBSEARCH_CMD="$ARDUINO lib search"
# LIBINSTALL_CMD="$ARDUINO lib install"

# for LIB in "${LIB_LIST[@]}"; do
#   echo "Searching $LIB in Library manager..."
#   if [[ "$($LIBSEARCH_CMD "$LIB" --names)" == *$LIB* ]]; then
#     echo "Library found in Library Manager Repo!)"
#     sleep 2
#     $LIBINSTALL_CMD "$LIB"
#   else
#     echo "$LIB library not found!"
#   fi
# done

# ---- git clone the firmware source code ---- #
# cd "$HOME" || return
# git clone https://github.com/dattasaurabh82/clock_firmware_production.git
