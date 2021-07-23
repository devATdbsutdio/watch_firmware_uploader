!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[0;37m'
RESET='\033[0m'


countdown() {
   msg=" > BACK TO MAIN PROMPT IN: "
   tput cup 11 0
   echo -e "${RED}$msg"
   l=${#msg}
   l=$(( l+2 ))
   for i in {10..0}
   do
     tput cup 11 $l
     echo -n "${RED}$i"
     echo -e "${RESET}"
     sleep 1
   done
   echo " "
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
 echo -e "${GREEN}$BANNER${RESET}" && echo " " && echo " "
 echo -e "${YELLOW} PRESS [ P ] THEN [ ENTER ] -> GET LATEST FIRMWARE."
 echo -e "${YELLOW} PRESS [ S ] THEN [ ENTER ] -> SELECT UPLOAD PORT [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ]."
 echo -e "${YELLOW} PRESS [ U ] THEN [ ENTER ] -> UPLOAD FIRMWARE [ YOUR DEVICE SHOULD BE CONNECTED FOR THIS STEP ].${RESET}" && echo " "
 read -r -p "  > " input
 case $input in
   [pP])
 clear && echo -e "${GREEN}$BANNER${RESET}" && echo -e "${YELLOW} > PULLING LATEST FIRMWARE FROM REPOSITORY ...${RESET}" && echo " "
 FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
 FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock
 echo -e "${YELLOW} > EXECUTING: 'cd $FIRMWARE_REPO_DIR && git pull && cd $HOME'${RESET}"
 cd $FIRMWARE_REPO_DIR && git pull && cd $HOME
 sleep 2
 clear
 ;;
  [sS])
 clear && echo -e "${GREEN}$BANNER${RESET}" && echo -e "${YELLOW} > SELECT THE CORRECT UPLOAD PORT [ USE THE NUMPAD + ENTER ]${RESET}"
 IFS=$'\n' ports=( $(ls /dev/tty*) )
 select port in "${ports[@]}"; do
   FIRMWARE_REPO_DIR=$HOME/clock_firmware_production
   FIRMWARE_DIR=$FIRMWARE_REPO_DIR/clock

   UPLOAD_CMD=($HOME/bin/arduino-cli compile -b megaTinyCore:megaavr:atxy7:chip=1607,clock=5internal,bodvoltage=1v8,bodmode=disabled,eesave=enable,millis=enabled,resetpin=UPDI,startuptime=0,uartvoltage=skip $FIRMWARE_DIR -u -p $port -P pyupdi -t)
   echo " " && echo " " && echo -e "${GREEN}SELECTED PORT IS:{RESET} [ $REPLY ] $port${RESET}" && countdown ; break
 done
 clear
 ;;
   [uU])
 clear && echo -e "${GREEN}$BANNER${RESET}" && echo -e "${YELLOW} > UPLOADING FIRMWARE NOW${RESET}" && echo " "
 #echo " > EXECUTING: ${UPLOAD_CMD[*]}"
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
 
