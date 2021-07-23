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
 # the git for latest firmware should have been cloned for this to work by installer script
 # cd $HOME/clock_firmware_production && git pull && cd $HOME
 sleep 2
 clear
 ;;
  [sS])
 clear
 echo "$BANNER"
 echo "Select the right port [use the num keys]:"
 IFS=$'\n' ports=( $(ls /dev/tty*) )
 select port in "${ports[@]}"; do
   UPLOAD_CMD="arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip --output-dir ./build/ -u -p $port -P pyupdi57k -t"
   echo "Selected port is: [$REPLY] $port" && sleep 5 ; break
 done 
 sleep 1
 clear
 ;;
   [uU])
 clear
 echo "$BANNER"
 echo "Uploading firmware now..."
 # cd $HOME/clock_firmware_production && $UPLOAD_CMD && cd $HOME
 echo "$UPLOAD_CMD"
 echo "$port"
 sleep 5
 clear
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
 
