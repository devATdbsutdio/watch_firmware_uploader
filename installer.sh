#!/bin/bash

# ---- color info ---- #
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
# -------------------- #

ymal_parse="$(/usr/bin/which yq)" #used for parsing setting file

# ------- values top be prased from settings file ------- #
CLI_DOWNLOAD_LINK=""
BIN_BASE_DIR=""
CORE_URLS=()
ARDUINO=""
CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml
CORES=() # array of FQBN cores like [megaTinyCore:megaavr, ...]
LIB_LIST=()

I_SETTING_FILE_NAME=installer_settings.yaml
P_SETTING_FILE_NAME=programmer_settings.yaml

FULL_PATH=$(realpath "$0")
SETTINGS_DIR=$(dirname "$FULL_PATH")

I_SETTINGS_FILE=$SETTINGS_DIR/$I_SETTING_FILE_NAME
P_SETTINGS_FILE=$SETTINGS_DIR/$P_SETTING_FILE_NAME

settings_found_loaded=false
cli_installed=false
cli_init_file_created=false
core_install_count=0
lib_install_count=0
firm_wares_cloned=false

process_list() {
  while true; do
    clear
    echo -e "${RESET}PROCESS STATUS:${RESET}"
    if [ $settings_found_loaded = true ]; then
      echo -e "${GREEN} [STEP 1] Settings File Located and Loaded${RESET}"
    else
      echo -e "${RED} [STEP 1] settings.yaml located  Loaded${RESET}"
    fi

    if [ $cli_installed = true ]; then
      echo -e "${GREEN} [STEP 2] arduino-cli is installed${RESET}"
    else
      echo -e "${RED} [STEP 2] arduino-cli is NOT installed${RESET}"
    fi

    if [ $cli_init_file_created = true ]; then
      echo -e "${GREEN} [STEP 3] cli init file created${RESET}"
    else
      echo -e "${RED} [STEP 3] cli init file NOT created${RESET}"
    fi

    if [ $core_install_count = "${#CORES[*]}" ] && [ ! $core_install_count = 0 ]; then
      echo -e "${GREEN} [STEP 4] Listed cores are installed${RESET}"
    elif [ ! $core_install_count = "${#CORES[*]}" ] && [ ! $core_install_count = 0 ]; then
      echo -e "${YELLOW} [STEP 4] Some cores are NOT installed${RESET}.Check ardunio-cli config!"
    else
      echo -e "${RED} [STEP 4] Listed cores are NOT installed${RESET}"
    fi

    if [ $lib_install_count = "${#LIB_LIST[*]}" ] && [ ! $lib_install_count = 0 ]; then
      echo -e "${GREEN} [STEP 5] Listed libraries are installed${RESET}"
    elif [ ! $lib_install_count = "${#LIB_LIST[*]}" ] && [ ! $lib_install_count = 0 ]; then
      echo -e "${YELLOW}[STEP 5] Some libraries are installed${RESET}.Check ardunio-cli config!"
    else
      echo -e "${RED} [STEP 5] Listed libraries are NOT installed${RESET}"
    fi

    if [ $firm_wares_cloned = true ]; then
      echo -e "${GREEN}[STEP 6] Firmwares are cloned${RESET}"
    else
      echo -e "${RED} [STEP 6] Firmwares are NOT cloned${RESET}"
    fi

    echo ""
    read -r -p "$(echo -e "${YELLOW}" Proceed to next step? [Y/n]: "${RESET}")" input
    # read -r -p "${YELLOW}  Proceed to next step? [Y/n]: ${RESET}" input"
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

# Show the list and task to do
clear
process_list

# -------- Read data in from settings file ------- #
clear
sleep 1
echo -e "${YELLOW}> Loading settings ...${RESET}"
sleep 1
if [ -f "$I_SETTINGS_FILE" ]; then
  echo -e "${GREEN}  TARGET SETTINGS EXIST IN: $I_SETTINGS_FILE${RESET}"

  CLI_DOWNLOAD_LINK="$($ymal_parse e '.BINARY.LINK' "$I_SETTINGS_FILE")"
  BIN_BASE_DIR=$($ymal_parse e '.BINARY.BASE' "$I_SETTINGS_FILE")

  # IFS=$'\t' CORE_URLS=($($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE"))
  IFS=$'\n' read -r -d '' -a CORE_URLS < <($ymal_parse e '.BINARY.CORES.LINK[]' "$I_SETTINGS_FILE")

  # IFS=$'\t' CORES=($($ymal_parse e '.BINARY.CORES.CORE_NAMES[]' "$I_SETTINGS_FILE"))
  IFS=$'\n' read -r -d '' -a CORES < <($ymal_parse e '.BINARY.CORES.CORE_NAMES[]' "$I_SETTINGS_FILE")

  # LIB_LIST=(TinyMegaI2C RV8803Tiny)
  # LIB_LIST=($($ymal_parse e '.LIBS[]' "$I_SETTINGS_FILE"))
  IFS=$'\n' read -r -d '' -a LIB_LIST < <($ymal_parse e '.LIBS[]' "$I_SETTINGS_FILE")

  sleep 2
  echo ""
  echo -e "${YELLOW}  arduni-cli path mentioned in settings file: $BIN_BASE_DIR/bin/ ${RESET}"
  echo ""
  echo -e "${GREEN} FOUND SETTINGS:${RESET}"
  echo -e "${BLUE}  CORE URLS:${RESET}"
  c=0
  for CORE_URL in ${CORE_URLS[*]}; do
    c=$((c + 1))
    echo -e "  [$c] $CORE_URL"
  done
  c=0
  echo ""
  echo -e "${BLUE}  CORES:${RESET}"
  for CORE in "${CORES[@]}"; do
    c=$((c + 1))
    echo -e "  [$c] $CORE"
  done
  c=0
  echo ""
  echo -e "${BLUE}  LIBRARIES:${RESET}"
  for LIB in "${LIB_LIST[@]}"; do
    c=$((c + 1))
    echo -e "  [$c] $LIB"
  done
  c=0

  sleep 10
  # Show the updated list and task to do
  settings_found_loaded=true
  process_list
else
  echo -e "${RED}TARGET SETTINGS file $I_SETTING_FILE_NAME doesn't seem to exist in: $SETTINGS_DIR/${RESET}"
  # Show the updated list and task to do
  settings_found_loaded=false
  process_list
  echo -e "${RED} QUITTING in 5 sec !${RESET}"
  sleep 5
  exit 1
fi
# ----------------------------- #

# ---- Install arduino-cli ---- #
# TBD:
# Install? Y/N
# if yes, then break
# if no: ask for installed path (Are you sure?):
#   check path: if binary is there:
#   if path is wrong: loop back as there was no binary in path

while true; do
  read -r -p "$(echo -e "${YELLOW}" Install arduino-cli in ? [Y/n]: "${RESET}")" answer
  case $answer in
  [y/Y])
    # move on and use the settings file provided path to install arduino-cli
    break
    ;;
  [n/N])
    #  ask user to provide absolute path of the arduino-cli bin
    read -r -p "$(echo -e "${RED}" Please provide arduino-cli absolute PATH \(/\<DIR\>/bin/arduino-cli\): "${RESET}")" cli_path
    # using find command check if the binary truely exists in the provided path
    find_bin_cmd="$(which find) / -type f -wholename \"*$cli_path\" 2>/dev/null"
    if [[ "$find_bin_cmd" ]]; then
      echo -e "arduino-cli is present in $cli_path"
      # if it is present, well then move on
      BIN_BASE_DIR=$cli_path
      sleep 3
      break
    else
      echo -e "arduino-cli is NOT present in $cli_path"
    fi
    ;;
  *)
    echo "Invalid input. Try again in 3 sec!"
    sleep 3
    ;;
  esac
done

sleep 1
echo -e "${YELLOW}> Installing arduino-cli in target base directory:${RESET} $BIN_BASE_DIR"
echo ""
sleep 2
echo -e "${YELLOW}> Entering <base>/bin Directory:${RESET} cd $BIN_BASE_DIR/bin"
sleep 2
mkdir -p -- "$BIN_BASE_DIR"/bin
cd "$BIN_BASE_DIR"/bin || exit
echo -e "${GREEN}  IN $BIN_BASE_DIR/bin now${RESET}"
sleep 2
echo ""
echo -e "${YELLOW}> Downloading arduino-cli...${RESET}"
echo ""
sleep 2
wget "$CLI_DOWNLOAD_LINK"
echo -e "${GREEN}  Download finished!${RESET}"
sleep 2
echo ""
echo -e "${YELLOW}> Unzipping...${RESET}"
tar -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
rm arduino-cli_latest_Linux_ARMv7.tar.gz && rm LICENSE.txt
echo ""
echo -e "${GREEN}  arduino-cli installed in:${RESET} $BIN_BASE_DIR/bin/arduino-cli"
ARDUINO=$BIN_BASE_DIR/bin/arduino-cli

# ** Update cli's location in programmer_settings.yaml
echo ""
echo -e "${YELLOW}> Updating programmer_setting.yaml with arduino-cli's location${RESET}"
echo ""
sleep 2
# ---- TEST ---- [TBD **]
echo "---------------------------"
$ymal_parse e ".BINARY.LOCATION = \"$ARDUINO\"" "$P_SETTINGS_FILE"
echo "---------------------------"
sleep 10
# go back to the home directory
cd "$HOME" || return

cli_installed=true
process_list

# ------ Create Arduino-cli init file and add board's in it [if it doesn't exist]------ #
echo -e "${YELLOW}> Looking for arduino-cli config file...${RESET}"
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED}  It doesn't exist!${RESET}"
  sleep 2
  echo -e "${YELLOW}  Creating now..${RESET}"
  echo ""
  "$ARDUINO" config init
  sleep 2
else
  echo -e "${GREEN}  It exists!${RESET}"
  sleep 2
fi
echo " "
echo -e "${YELLOW}> Adding found core links from settings in arduino's config...${RESET}"
sleep 2
for CORE_URL in "${CORE_URLS[@]}"; do
  echo " "
  if grep -q "$CORE_URL" "$CONFIG_FILE"; then
    echo -e "$CORE_URL ${GREEN}already exists in config file${RESET}"
  else
    echo -e "$CORE_URL ${RED}doesn't exist in config file!${RESET}"
    sleep 2
    echo -e "${GREEN}Adding $CORE_URL to config file${RESET}"
    sleep 2
    ADD_CORE_URL="$ARDUINO config add board_manager.additional_urls $CORE_URL"
    echo -e "${YELLOW}> EXECUTING:${RESET} $ADD_CORE_URL"
    $ADD_CORE_URL
  fi
done
echo "---------------------------"
"$ARDUINO" config dump
echo "---------------------------"
sleep 1
$ARDUINO core update-index
sleep 4

cli_init_file_created=true
process_list
# ---------------------------------------------------------------- #

# ----------------------- Install the Cores ---------------------- #
for CORE in "${CORES[@]}"; do
  echo ""
  echo -e "${YELLOW}> Searching $CORE ...${RESET}"
  SEARCH_CMD="$ARDUINO core search $CORE"
  if [[ ! "$($SEARCH_CMD)" =~ "No" ]]; then
    echo -e "${GREEN}  Core found. Installing now ...${RESET}"
    CORE_INSTALL_CMD="$ARDUINO core install $CORE"
    sleep 2
    echo " "
    $CORE_INSTALL_CMD
    echo " "
    core_install_count=$((core_install_count + 1))
  else
    echo -e "${RED} No such Core !${RESET}"
    sleep 2
  fi
done
process_list
# ---------------------------------------------------------------- #

# --------------- Install the necessary libraries  --------------- #
LIBINSTALL_CMD="$ARDUINO lib install"

for LIB in "${LIB_LIST[@]}"; do
  echo ""
  echo -e "${YELLOW}> Searching $LIB in Library manager ...${RESET}"
  LIBSEARCH_CMD="$ARDUINO lib search $LIB --names"
  if [[ "$($LIBSEARCH_CMD)" == *$LIB* ]]; then
    echo -e "${GREEN}  Library found in Library Manager Repo!${RESET})"
    sleep 2
    echo " "
    LIBINSTALL_CMD="$ARDUINO lib install $LIB"
    $LIBINSTALL_CMD
    echo " "
    lib_install_count=$((lib_install_count + 1))
  else
    echo -e "${RED}. $LIB library not found!${RESET}"
    sleep 2
  fi
done
process_list
# ---------------------------------------------------------------- #

# ---- git clone the firmware source code ---- #
# cd "$HOME" || return
# git clone https://github.com/dattasaurabh82/clock_firmware_production.git
