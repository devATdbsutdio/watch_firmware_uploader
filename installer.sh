#!/usr/bin/env bash

# ---- color info ---- #
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
# -------------------- #

ymal_parse="$(/usr/bin/which yq)" # used for parsing setting file
tar_parse="$(/usr/bin/which tar)"
git_parse="$(/usr/bin/which git)"

# ------- values top be prased from settings file ------- #
CLI_DOWNLOAD_LINK=""
BIN_BASE_DIR=""
CORE_URLS=()
ARDUINO=""
CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml
CORES=() # array of FQBN cores like [megaTinyCore:megaavr, ...]
LIB_LIST=()
FIRMWARE_LINKS=()

I_SETTING_FILE_NAME=installer_settings.yaml
P_SETTING_FILE_NAME=programmer_settings.yaml

FULL_PATH=$(realpath "$0")
# TBD: go one dir back
SETTINGS_DIR=$(dirname "$FULL_PATH")

I_SETTINGS_FILE=$SETTINGS_DIR/$I_SETTING_FILE_NAME
P_SETTINGS_FILE=$SETTINGS_DIR/$P_SETTING_FILE_NAME

settings_found_loaded=false
cli_installed=false
cli_init_file_created=false
core_install_count=0
lib_install_count=0
firm_wares_cloned=false
steps=0

install_proj_requirements() {
  clear
  sleep 1
  echo "Installing npyscreen, pyyaml ifaddr using pip3"
  sleep 1
  echo ""
  pip3 install npyscreen
  pip3 install pyyaml
  pip3 install ifaddr
  clear
  sleep 1
  echo "Installing pyserial, thermalprinter and PIL using pip3"
  sleep 1
  echo ""
  pip3 install pyserial
  python3 -m pip install --upgrade --user pyserial
  python3 -m pip install --upgrade --user thermalprinter
  python3 -m pip install --upgrade --user pytest
  python3 -m pip install --upgrade Pillow
  clear
  sleep 1
  echo "nodejs and frontail"
  sleep 1
  echo ""
  sudo apt install nodejs -y
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  brc # source bashrc alias
  nvm install node
  nvm install --lts
  clear
  sleep 1
  sudo npm i frontail -g
  clear
  sleep 1
  echo "Done the rest of sys installations"
  sleep 2
}

next_step() {
  echo ""
  read -r -p "$(echo -e "${YELLOW}" Press any key to continue: "${RESET}")" next
  case $next in
  *) ;;

  esac
}

on_finish_setup() {
  # we have reached the end, hoping all the installations were done and setup were done correctly
  clear
  read -r -p "$(echo -e "${GREEN}" All Set! REBOOT NOW [Y/n]: "${RESET}")" reboot
  case $reboot in
  [y/Y])
    # reboot [TBD]
    ;;
  [n/N])
    sleep 1
    clear
    exit 1
    ;;
  *)
    echo -e "${RED} Invalid input. Try Again!${RESET}"
    sleep 1
    ;;
  esac
}

process_list() {
  while true; do
    clear
    echo -e "${RESET}PROCESS STATUS:${RESET}"
    if [ $settings_found_loaded = true ]; then
      echo -e "${GREEN} [STEP 1] \"installer_settings.yaml\" Located and Loaded${RESET}"
    else
      if [ $steps = 0 ]; then
        echo -e "${RED} [STEP 1] Must try to load \"installer_settings.yaml\" before anything else. Do it?${RESET}"
      else
        echo -e "${RED} [STEP 1] \"installer_settings.yaml\" Not Loaded${RESET}"
      fi
    fi

    if [ $cli_installed = true ]; then
      echo -e "${GREEN} [STEP 2] \"arduino-cli\" is now installed/asigned${RESET}"
    else
      if [ $steps = 0 ] || [ $steps = 1 ]; then
        echo -e "${RED} [STEP 2] \"arduino-cli\" location not assigned. It may not be installed as well. Check?${RESET}"
      else
        echo -e "${RED} [STEP 2] \"arduino-cli\" potentially not installed${RESET}"
      fi
    fi

    if [ $cli_init_file_created = true ]; then
      echo -e "${GREEN} [STEP 3] Made sure arduino-cli's config file is there${RESET}"
    else
      if [ $steps = 0 ] || [ $steps = 2 ]; then
        echo -e "${RED} [STEP 3] Not sure if arduino-cli's config file is there or not! Check?${RESET}"
      else
        echo -e "${RED} [STEP 3] arduino-cli's config file could not be created!${RESET}"
      fi
    fi

    if [ $core_install_count = "${#CORES[*]}" ] && [ ! $core_install_count = 0 ]; then
      echo -e "${GREEN} [STEP 4] All the listed cores (from provided settings) must have been installed!${RESET}"
    elif [ ! $core_install_count = "${#CORES[*]}" ] && [ ! $core_install_count = 0 ]; then
      echo -e "${YELLOW} [STEP 4] Some cores are NOT installed${RESET}.Consult ardunio-cli config!"
    else
      if [ $steps = 0 ] || [ $steps = 3 ]; then
        echo -e "${RED} [STEP 4] Not sure if the listed cores (from provided settings) are installed! Check?${RESET}"
      else
        echo -e "${RED} [STEP 4] None of the listed cores (from provided settings) are installed!${RESET}"
      fi
    fi

    if [ $lib_install_count = "${#LIB_LIST[*]}" ] && [ ! $lib_install_count = 0 ]; then
      echo -e "${GREEN} [STEP 5] All the listed libraries (from provided settings) must have been installed!${RESET}"
    elif [ ! $lib_install_count = "${#LIB_LIST[*]}" ] && [ ! $lib_install_count = 0 ]; then
      echo -e "${YELLOW} [STEP 5] Some libraries are not installed${RESET}.Consult ardunio-cli config!"
    else
      if [ $steps = 0 ] || [ $steps = 4 ]; then
        echo -e "${RED} [STEP 5] Not sure if the listed libraries (from provided settings) are installed! Check?${RESET}"
      else
        echo -e "${RED} [STEP 5] None of the listed libraries are (from provided settings) installed${RESET}"
      fi
    fi

    if [ $firm_wares_cloned = true ] && [ ! $lib_install_count = 0 ]; then
      echo -e "${GREEN}[STEP 6] Firmwares are cloned !${RESET}"
    else
      echo -e "${RED} [STEP 6] Firmwares loaction: Not sure. Check?${RESET}"
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
      sleep 1
      exit 1
      ;;
    *)
      echo "Invalid input"
      ;;
    esac
  done
  clear

  # THE END
  if [ $steps = 6 ]; then
    # Do rest fo the installation ...
    install_proj_requirements
    #  we have reached the end
    on_finish_setup
  fi
}

# Show the list and task to do
clear
process_list

# -------- Read data in from settings file ------- #
clear
sleep 1
echo -e "${YELLOW} Loading settings ...${RESET}"
sleep 1
if [ -f "$I_SETTINGS_FILE" ]; then
  echo -e "${GREEN} TARGET SETTINGS EXIST IN: $I_SETTINGS_FILE${RESET}"

  CLI_DOWNLOAD_LINK="$($ymal_parse e '.BINARY.LINK' "$I_SETTINGS_FILE")"
  BIN_BASE_DIR="$($ymal_parse e '.BINARY.BASE' "$I_SETTINGS_FILE")"
  # -- Add "/" at the end of PATH if it doesn't exist
  case "$BIN_BASE_DIR" in
  */) ;;

  *)
    BIN_BASE_DIR=$BIN_BASE_DIR/
    ;;
  esac

  IFS=$'\n' read -r -d '' -a CORE_URLS < <($ymal_parse e '.BINARY.CORES.LINKS[]' "$I_SETTINGS_FILE")
  IFS=$'\n' read -r -d '' -a CORES < <($ymal_parse e '.BINARY.CORES.CORE_NAMES[]' "$I_SETTINGS_FILE")
  IFS=$'\n' read -r -d '' -a LIB_LIST < <($ymal_parse e '.LIBS[]' "$I_SETTINGS_FILE")
  IFS=$'\n' read -r -d '' -a FIRMWARE_LINKS < <($ymal_parse e '.FIRMWARE.LINKS[]' "$I_SETTINGS_FILE")

  sleep 2
  echo ""
  echo -e "${GREEN} FOUND SETTINGS:${RESET}"
  echo ""
  echo -e "${BLUE} ardunio-cli path mentioned in settings file:${RESET} ${BIN_BASE_DIR}arduino-cli"
  echo ""
  echo -e "${BLUE} CORE URLS:${RESET}"
  c=0
  for CORE_URL in ${CORE_URLS[*]}; do
    c=$((c + 1))
    echo -e " [$c] $CORE_URL"
  done
  c=0
  echo ""
  echo -e "${BLUE} CORES:${RESET}"
  for CORE in "${CORES[@]}"; do
    c=$((c + 1))
    echo -e " [$c] $CORE"
  done
  c=0
  echo ""
  echo -e "${BLUE} LIBRARIES:${RESET}"
  for LIB in "${LIB_LIST[@]}"; do
    c=$((c + 1))
    echo -e " [$c] $LIB"
  done
  c=0
  echo ""
  echo -e "${BLUE} FIRMWARE REPOS:${RESET}"
  for git_clone_link in "${FIRMWARE_LINKS[@]}"; do
    c=$((c + 1))
    echo -e " [$c] $git_clone_link"
  done
  c=0

  settings_found_loaded=true
else
  echo -e "${RED} TARGET SETTINGS file $I_SETTING_FILE_NAME doesn't seem to exist in: $SETTINGS_DIR/${RESET}"
  # Show the updated list and task to do
  settings_found_loaded=false
  echo -e "${RED} QUITTING in 5 sec !${RESET}"
  sleep 5
  exit 1
fi
# ----------------------------- #
steps=$((steps + 1))
next_step
process_list

# ---- Install arduino-cli ---- #
cli_present=false

while true; do
  echo ""
  read -r -p "$(echo -e "${YELLOW}" Install arduino-cli in "${BIN_BASE_DIR}"? [Y/n]: "${RESET}")" answer
  case $answer in
  [y/Y])
    # move on and use the settings file provided path to install arduino-cli
    cli_present=false
    break
    ;;
  [n/N])
    #  ask user to provide absolute path of the arduino-cli binary
    while true; do
      read -e -p "$(echo -e "${RED}" Assuming \"arduino-cli\" is already installed, please provide the absolute PATH":${RESET} ")" cli_path
      echo -e "${BLUE} User provided path:${RESET} $cli_path"
      sleep 2
      # -- Check for slash, if it is not there; add
      case "$cli_path" in
      */)
        # echo "has slash"
        ;;
      *)
        # echo "doesn't have have slash"
        cli_path=$cli_path/
        ;;
      esac

      SP=${cli_path}arduino-cli
      # using find command to check if the binary truely exists in the provided path
      if [ -f "$SP" ]; then
        echo -e "${GREEN} \"arduino-cli\" is present in:${RESET} $cli_path"
        BIN_BASE_DIR=$cli_path
        cli_present=true
        sleep 3
        break
      else
        echo -e "${RED} \"arduino-cli\" is NOT present in${RESET} $cli_path"
        # [TBD] - check again or download?
        sleep 3
      fi
    done
    break
    ;;
  *)
    echo -e "${RED} Invalid input.${RESET} Try again in 3 sec!"
    sleep 3
    ;;
  esac
done

ARDUINO=${BIN_BASE_DIR}arduino-cli

if [ "$cli_present" = false ]; then
  sleep 1
  echo -e "${YELLOW} Installing \"arduino-cli\" in target base directory:${RESET} $BIN_BASE_DIR"
  echo ""
  sleep 2
  echo -e "${YELLOW} Entering Directory:${RESET} cd ${BIN_BASE_DIR}"
  sleep 2
  mkdir -p -- "$BIN_BASE_DIR"
  cd "$BIN_BASE_DIR" || exit
  echo -e "${GREEN} IN ${BIN_BASE_DIR} now${RESET}"
  sleep 2
  echo ""
  echo -e "${YELLOW} Downloading \"arduino-cli\"...${RESET}"
  echo ""
  sleep 2
  wget "$CLI_DOWNLOAD_LINK"
  echo -e "${GREEN} Download finished!${RESET}"
  sleep 2
  echo ""
  echo -e "${YELLOW} Unzipping...${RESET}"
  $tar_parse -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
  rm arduino-cli_latest_Linux_ARMv7.tar.gz && rm LICENSE.txt
  echo ""
  echo -e "${GREEN} \"arduino-cli\" installed in:${RESET} $BIN_BASE_DIR"
fi

# ** Update cli's location in programmer_settings.yaml
echo ""
echo -e "${YELLOW} Updating \"programmer_setting.yaml\" with arduino-cli's location${RESET}"
echo ""
sleep 2
echo "---------------------------"
$ymal_parse e ".BINARY.LOCATION = \"$ARDUINO\"" -i "$P_SETTINGS_FILE"
# show updated file
$ymal_parse e "$P_SETTINGS_FILE"
echo "---------------------------"
# go back to the home directory
cd "$HOME" || return

cli_installed=true
steps=$((steps + 1))
next_step
process_list

# ------ Create arduino-cli config file and add board's in it [if it doesn't exist]------ #
echo -e "${YELLOW} Looking for arduino-cli's config file...${RESET}"
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED} It doesn't exist!${RESET}"
  sleep 5
  echo -e "${YELLOW} Creating now..${RESET}"
  echo ""
  "$ARDUINO" config init
  sleep 5
else
  echo -e "${GREEN} It exists!${RESET}"
  sleep 2
fi
echo " "
echo -e "${YELLOW} Adding found core links from settings in arduino's config...${RESET}"
sleep 5
for CORE_URL in "${CORE_URLS[@]}"; do
  echo " "
  if grep -q "$CORE_URL" "$CONFIG_FILE"; then
    echo -e " $CORE_URL ${GREEN}already exists in config file${RESET}"
  else
    echo -e " $CORE_URL ${RED}doesn't exist in config file!${RESET}"
    sleep 5
    echo -e "${GREEN} Adding $CORE_URL to config file${RESET}"
    sleep 5
    ADD_CORE_URL="$ARDUINO config add board_manager.additional_urls $CORE_URL"
    echo -e "${YELLOW} EXECUTING:${RESET} $ADD_CORE_URL"
    $ADD_CORE_URL
  fi
done
echo " "
echo -e "${YELLOW} Enabling unsafe install of libraries from git ...${RESET}"
ENABLE_UNSAFE_INSTALL="$ARDUINO config set library.enable_unsafe_install true"
$ENABLE_UNSAFE_INSTALL
echo -e "${RED} Enabled unsafe install of libraries from git!${RESET}"
echo " "
echo "---------------------------"
# "$ARDUINO" config dump
# echo " "
$ymal_parse e "$HOME"/.arduino15/arduino-cli.yaml
echo "---------------------------"
sleep 5
$ARDUINO core update-index
# sleep 5

cli_init_file_created=true
steps=$((steps + 1))
next_step
process_list
# ---------------------------------------------------------------- #

# ----------------------- Install the Cores ---------------------- #
for CORE in "${CORES[@]}"; do
  echo ""
  echo -e "${YELLOW} Searching $CORE ...${RESET}"
  SEARCH_CMD="$ARDUINO core search $CORE"
  if [[ ! "$($SEARCH_CMD)" =~ "No" ]]; then
    echo -e "${GREEN} Core found. Installing now ...${RESET}"
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
echo ""
$ARDUINO core upgrade

steps=$((steps + 1))
next_step
process_list
# ---------------------------------------------------------------- #

# --------------- Install the necessary libraries  --------------- #
LIBINSTALL_CMD=""
lib_install_count=0
for LIB in "${LIB_LIST[@]}"; do
  echo ""
  echo -e "${YELLOW} Parsing libraries list from the settings file ...${RESET}"
  sleep 2
  if [[ $LIB = *"https:"* ]]; then
    # parse the end of the git link to get lib's name
    LIB_NAME=$(echo "$LIB" | cut -d'/' -f 5)
    LIB_NAME_LEN_WITH_GIT=${#LIB_NAME}
    IDX_OF_DOT=$((LIB_NAME_LEN_WITH_GIT - 4))
    LIB_NAME=${LIB_NAME:0:$IDX_OF_DOT}

    echo -e "${BLUE} $LIB_NAME src is from a git link${RESET}"
    echo " "
    echo -e "${YELLOW} Installing $LIB_NAME from git ...${RESET}"
    LIBINSTALL_CMD="$ARDUINO lib install --git-url $LIB"
    $LIBINSTALL_CMD
    echo " "

    lib_install_count=$((lib_install_count + 1))

  else
    echo -e "${BLUE} $LIB is a pure lib name${RESET}"

    LIBSEARCH_CMD="$ARDUINO lib search $LIB --names"
    LIBINSTALL_CMD="$ARDUINO lib install $LIB"

    echo -e "${YELLOW} Searching $LIB in Library manager ...${RESET}"

    LIBSEARCH_CMD="$ARDUINO lib search $LIB --names"

    if [[ "$($LIBSEARCH_CMD)" == *$LIB* ]]; then
      echo -e "${GREEN} $LIB found in Library Manager!${RESET}"
      sleep 2
      echo -e "${YELLOW} Installing $LIB from Library Manager ...${RESET}"
      LIBINSTALL_CMD="$ARDUINO lib install $LIB"
      $LIBINSTALL_CMD
      echo " "

      lib_install_count=$((lib_install_count + 1))

    else
      echo -e "${RED} $LIB not found in Library Manager!${RESET}"
      echo " "
      sleep 2
    fi
  fi
done
# incerement step count
steps=$((steps + 1))
next_step
process_list
# ---------------------------------------------------------------- #
# reset lib installation counter
lib_install_count=0

# ---- git clone the firmware source code ---- #
sketchbook_loc="${HOME}/Arduino/sketchbook/"
echo -e "${YELLOW} Entering sketchbook location by:${RESET} cd $sketchbook_loc"
mkdir -p -- "$sketchbook_loc"
cd "$sketchbook_loc" || return

i=0
echo -e "${YELLOW} Parsing the git links ... ${RESET}"
for git_clone_link in "${FIRMWARE_LINKS[@]}"; do
  # --- parse the end of the git link to get sketch's dir name
  # -- FOR HTTPS git links
  # SKETCH_NAME_LEN_WITH_GIT=${#SKETCH_NAME}
  # IDX_OF_DOT=$((SKETCH_NAME_LEN_WITH_GIT - 4))
  # SKETCH_NAME=${SKETCH_NAME:0:$IDX_OF_DOT}
  # -- FOR SSH git links
  IFS='/' read -ra parts_of_link <<<"$git_clone_link"
  SKETCH_NAME_WITH_GIT=${parts_of_link[1]}
  SKETCH_NAME_LEN_WITH_GIT=${#SKETCH_NAME_WITH_GIT}
  IDX_OF_DOT=$((SKETCH_NAME_LEN_WITH_GIT - 4))
  SKETCH_NAME=${SKETCH_NAME_WITH_GIT:0:$IDX_OF_DOT}

  firmware_loc=$sketchbook_loc$SKETCH_NAME

  # if sketch already exists, git pull
  if [ -d "$firmware_loc" ]; then
    echo -e "${BLUE} File already exists.${RESET} ${YELLOW}So pulling ...${RESET}"
    echo " "
    # cd "$firmware_loc" && $git_parse pull
    cd "$firmware_loc" && git checkout production && git up
  else
    echo -e "${YELLOW} [$i] Cloning $git_clone_link to${RESET} $sketchbook_loc"
    $git_parse clone "$git_clone_link"
  fi
  cd "$HOME" || return

  # enter the path in programmer settings
  echo -e "${GREEN} Firmware-$i is now in system at:${RESET} $firmware_loc"
  sleep 1
  echo -e "${YELLOW} Entering this location PATH in${RESET} $P_SETTING_FILE_NAME ..."

  # Enter it in settings
  $ymal_parse e ".FIRMWARE.SKETCHES[$i] = \"$firmware_loc\"" -i "$P_SETTINGS_FILE"
  echo -e "${GREEN} DONE!${RESET}"
  echo " "
  echo "-------------------"
  $ymal_parse e "$P_SETTINGS_FILE"
  echo "-------------------"
  i=$((i + 1))
done
firm_wares_cloned=true
steps=$((steps + 1))

next_step
process_list
#FIRMWARE
