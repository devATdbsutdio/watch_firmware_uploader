!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[0;37m'
RESET='\033[0m'


countdown() {
   msg=" > BACK TO MAIN PROMPT IN: "
   tput cup 10 5
   echo "$msg"
   l=${#msg}
   l=$(( l+5 ))
   for i in {5..0}
   do
     tput cup 10 $l
     echo -n "$i"
     sleep 1
   done
}


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
 echo -e "${GREEN}$BANNER${RESET}" && echo " " && echo "${YELLOW}"
 echo -e " PRESS [ P ] THEN [ ENTER ] -> GET LATEST FIRMWARE."
 echo -e " PRESS [ S ] THEN [ ENTER ] -> SELECT UPLOAD PORT [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ]."
 echo -e " PRESS [ U ] THEN [ ENTER ] -> UPLOAD FIRMWARE [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ]." && echo "${RESET}"
 read -r -p "  > " input
 case $input in
   [pP])
 clear && echo "${GREEN}$BANNER${RESET}" && echo "${YELLOW} > PULLING LATEST FIRMWARE FROM REPOSITORY ..." && echo " "
 FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
 FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock
 echo " > EXECUTING: 'cd $FIRMWARE_REPO_DIR && git pull && cd $HOME'"
 cd $FIRMWARE_REPO_DIR && git pull && cd $HOME
 sleep 2
 clear
 ;;
  [sS])
 clear && echo "${GREEN}$BANNER${RESET}" && echo "${YELLOW} > SELECT THE CORRECT UPLOAD PORT [ USE THE NUMPAD + ENTER ]${RESET}"
 IFS=$'\n' ports=( $(ls /dev/tty*) )
 select port in "${ports[@]}"; do
   FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
   FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock

   UPLOAD_CMD=($HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p $port -P pyupdi -t)
   echo " " && echo " " && echo "${GREEN}SELECTED PORT IS:{RESET} [ $REPLY ] $port" && countdown ; break
 done
 clear
 ;;
   [uU])
 clear && echo "${GREEN}$BANNER${RESET}" && echo "${YELLOW} > UPLOADING FIRMWARE NOW" && echo " "
 echo " > EXECUTING: $UPLOAD_CMD${RESET}"
 "${UPLOAD_CMD[@]}"
 cd $HOME
 countdown
 ;;
  *)
 clear && echo "${GREEN}$BANNER${RESET}" && echo "${RED} > INVALID INPUT ${RESET}"
 countdown
 clear
 ;;
 esac
done
 
