#!/bin/bash

clear
sleep 1

# ---- SYS UPDATE & UPGRADE ---- #
while true
do
 read -r -p "Want to update and upgrade system? [Y/n] " input
 case $input in
     [yY][eE][sS]|[yY])
 clear
 apt-get update -y
 apt-get upgrade -y
 clear
 echo "System Updated!"
 sleep 2
 clear	
 break
 ;;
     [nN][oO]|[nN])
 clear
 echo "Moving on."
 break
        ;;
      *)
 echo "Invalid input..."
 ;;
 esac
done


# ---- Install arduino-cli ---- #
: '
sleep 1
echo "Going to home directory..."
cd $HOME
sleep 2
echo "Making \"bin\" directory..."
mkdir bin
sleep 2
oecho "Going to $HOME/bin ..."
cd $HOME/bin
sleep 2
echo "Downloading arduino-cli..."
sleep 2
clear 
wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARMv7.tar.gz
clear
echo "Download finished!"
sleep 2
clear
echo "Unzipping..."
tar -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
rm arduino-cli_latest_Linux_ARMv7.tar.gz
rm LICENSE.txt
echo "arduino-cli installed in $HOME/bin/arduino-cli"
sleep 4
clear
sleep 1
cd $HOME/clock_uploader_machine
'

# ---- Create Arduino-cli init file [if it doesn't exist]---- #
CONFIG_FILE=$HOME/.arduino15/arduino-cli.yaml
[ ! -f $CONFIG_FILE ] && $HOME/bin/arduino-cli config init && echo "There is Config file now!"

sleep 2

# ---- Add in board's manager additonal urls for MegaTinyCore ---- #
echo "Adding core url to config"

$HOME/bin/arduino-cli config add board_manager.additional_urls http://drazzy.com/package_drazzy.com_index.json

# ---- Install the megaTinyCore ---- #
clear
echo "Searching Core...\n"

CORE=megaTinyCore
CORE_EXT=megaavr

SEARCH_CMD="$HOME/bin/arduino-cli core search $CORE"
#CORE_INSTALL_CMD=$HOME/bin/arduino-cli core install $CORE:$CORE_EXT
CORE_INSTALL_CMD="echo \"core found install now...\""
 
[[ ! "$($SEARCH_CMD" =~ "No" ]] && $CORE_INSTALL_CMD




















