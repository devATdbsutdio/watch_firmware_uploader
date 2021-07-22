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
CORE_URL=http://drazzy.com/package_drazzy.com_index.json
ADD_CORE_URL="$HOME/bin/arduino-cli config add board_manager.additional_urls $CORE_URL"

if [ grep -q "$CORE_URL" "$CONFIG_FILE" ]
then
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
clear
echo "Searching Core..."

CORE=megaTinyCore
CORE_EXT=megaavr
SEARCH_CMD="$HOME/bin/arduino-cli core search $CORE"
CORE_INSTALL_CMD="$HOME/bin/arduino-cli core install $CORE:$CORE_EXT"

if [ ! "$($SEARCH_CMD)" =~ "No" ]
then
  echo "Core found. Installing now ..."
  sleep 2
  $CORE_INSTALL_CMD
elif [ "$($SEARCH_CMD)" =~ "No" ]
then
  echo "No such Core !"
  sleep 2
fi

# [[ ! "$($SEARCH_CMD)" =~ "No" ]] && $CORE_INSTALL_CMD




















