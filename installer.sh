#!/bin/bash

# Install arduino-cli, will install it in /home/pi/bin/ dir
# curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

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

# ---- GIT INSTALL ---- #
clear
echo "Installing git..."
apt-get install git -y
clear 
echo "git installed!"
sleep 2
clear


#Install python3
#Install pip3


# ---- Install arduino-cli ---- #
sleep 1
echo "Going to home directory..."
cd $HOME
sleep 2
echo "Making \"bin\" directory..."
mkdir bin
sleep 2
#echo "Editing bashrc..."
#if ! echo 'export PATH=/home/pi/bin:$PATH' >> $HOME/.bashrc; then
#    echo "Could Not Edit Bash !"
#fi
#echo "sourcing bashrc... [Temporarily deactivated]" 
#sudo source home/pi/.bashrc
#sleep 2
echo "Going to $HOME/bin ..."
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
