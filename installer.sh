#!/bin/bash -i

# Install arduino-cli, will install it in /home/pi/bin/ dir
# curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

clear

sleep 1
echo "Going to home directory..."
cd $HOME

sleep 1
echo "Making \"bin\" directory..."
mkdir bin

sleep 1
echo "Editing bashrc..."

if ! echo 'export PATH=/home/pi/bin:$PATH' >> $HOME/.bashrc; then
    echo "Could Not Edit Bash !"
fi 
#sudo source home/pi/.bashrc

sleep 1
echo "Going to $HOME/bin ..."
cd $HOME/bin

sleep 1
echo "Downloading arduino-cli..."
sleep 2
clear 
wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARMv7.tar.gz
clear
echo "Download finished"
sleep 2
clear
echo "Unzipping..."
tar -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
rm arduino-cli_latest_Linux_ARMv7.tar.gz
rm LICENSE.txt
clear
sleep 1
cd $HOME/clock_uploader_machine




