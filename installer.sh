#!/bin/bash -i

# Install arduino-cli, will install it in /home/pi/bin/ dir
# curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

cd\
mkdir /home/pi/bin
sudo echo 'export PATH=/home/pi/bin:$PATH' >> ~/.bashrc 
sudo source home/pi/.bashrc
cd /home/pi/bin
wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARMv7.tar.gz
tar -xvzf arduino-cli_latest_Linux_ARMv7.tar.gz
rm LICENSE.txt
rm arduino-cli_latest_Linux_ARMv7.tar.gz
cd\




