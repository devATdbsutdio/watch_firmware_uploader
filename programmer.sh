!/bin/bash

clear 
sleep 1

#ls /dev/tty.*
#PROMPT_STR=$'\"P\" = pull firmware. \"U\" = upload firmware. \"S\" = Select port: '

BANNER="
   __ _                                       
  / _(_)_ __ _ __ _____      ____ _ _ __ ___  
 | |_| | '__| '_ \` _ \ \ /\ / / _\` | '__/ _ \ 
 |  _| | |  | | | | | \ V  V / (_| | | |  __/ 
 |_| |_|_|  |_| |_| |_|\_/\_/ \__,_|_|  \___| 
  _   _ _ __ | | ___   __ _  __| | ___ _ __   
 | | | | '_ \| |/ _ \ / _\` |/ _\` |/ _ \ '__|  
 | |_| | |_) | | (_) | (_| | (_| |  __/ |     
  \__,_| .__/|_|\___/ \__,_|\__,_|\___|_|     
       |_|                                                             
"

while true
do
 clear
 echo "$BANNER"
 read -r -p "P = Pull latest firmware. S = Select upload port. U = To upload firmware: " input
 case $input in
   [pP])
 clear
 echo "$BANNER"
 echo "Pulling the latest firmware from git..."
 FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
 FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock
 cd $FIRMWARE_REPO_DIR && git pull && cd $HOME
 sleep 2
 clear
 ;;
  [sS])
 clear
 echo "$BANNER"
 echo "Select the right port [use the num keys]:"
 IFS=$'\n' ports=( $(ls /dev/tty*) )
 select port in "${ports[@]}"; do
   FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
   FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock
   #UPLOAD_CMD="$HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p $port -P pyupdi -t"
   UPLOAD_CMD="$HOME/bin/arduino-cli compile /-/-help"
   echo " " && echo " " && echo "Selected port is: [$REPLY] $port" && sleep 4 ; break
 done 
 sleep 1
 clear
 ;;
   [uU])
 clear
 echo "$BANNER"
 echo "Uploading firmware now..."
 echo " "
 sleep 2
 echo "$UPLOAD_CMD"
 $HOME/bin/arduino-cli compile --help
 cd $HOME
 sleep 10
 #clear
 ;;
  *)
 clear 
 echo "$BANNER"
 echo "Invalid input..."
 sleep 3
 clear
 ;;
 esac
done
 
