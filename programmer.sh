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
 echo "$BANNER" && echo " " && echo " "
 echo " PRESS [ P ] THEN [ ENTER ] -> GET LATEST FIRMWARE."
 echo " PRESS [ S ] THEN [ ENTER ] -> SELECT UPLOAD PORT [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ]."
 echo " PRESS [ U ] THEN [ ENTER ] -> UPLOAD FIRMWARE [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ]." && echo " "
 read -r -p "  > " input
 case $input in
   [pP])
 clear && echo "$BANNER" && echo " > PULLING LATEST FIRMWARE FROM REPOSITORY ..." && echo " "
 FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
 FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock
 echo " > EXECUTING: 'cd $FIRMWARE_REPO_DIR && git pull && cd $HOME'"
 cd $FIRMWARE_REPO_DIR && git pull && cd $HOME
 sleep 2
 clear
 ;;
  [sS])
 clear && echo "$BANNER" && echo " > SELECT THE CORRECT UPLOAD PORT [ USE THE NUMPAD + ENTER ]"
 IFS=$'\n' ports=( $(ls /dev/tty*) )
 echo " " && echo " "
 select port in "${ports[@]}"; do
   FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
   FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock

   UPLOAD_CMD=($HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p $port -P pyupdi -t)
   echo " " && echo " " && echo "Selected port is: [$REPLY] $port" && sleep 4 ; break
 done 
 sleep 1
 clear
 ;;
   [uU])
 clear && echo "$BANNER" && echo " > UPLOADING FIRMWARE NOW" && echo " "
 echo " > EXECUTING: $UPLOAD_CMD"
 sleep 1
 "${UPLOAD_CMD[@]}"
 cd $HOME
 sleep 5
 ;;
  *)
 clear && echo "$BANNER" && echo " > INVALID INPUT :["
 sleep 3
 clear
 ;;
 esac
done
 
