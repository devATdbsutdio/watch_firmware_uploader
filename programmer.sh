!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[0;37m'
RESET='\033[0m'


LINES=$(tput lines)

set_window (){
    # Create a virtual window that is two lines smaller at the bottom.
    tput csr 0 $(($LINES-2))
}

print_status (){
    # Move cursor to last line in your screen
    tput cup $LINES 0;

    #echo -n "--- FILE ---"
    echo -e '\x1b[41;37mSELECTED SERIAL PORT\x1b[K\x1b[0m'
    sleep 1

    # Move cursor to home position, back in virtual window
    tput cup 0 0
}

countdown() {
   msg=" > BACK TO MAIN PROMPT IN: "
   tput cup 11 0
   echo -e "${RED}$msg${RESET}"
   l=${#msg}
   l=$(( l ))
   for i in {5..0}
   do
     tput cup 11 $l
     echo -n "$i"
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


set_window

while true
do
 clear
 set_window
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
   #echo " " && echo " " && echo -e "${GREEN}SELECTED PORT IS:{RESET} [ $REPLY ] $port${RESET}" && countdown ; break
 print_status ; break
 done
 clear
 ;;
   [uU])
 clear && echo -e "${GREEN}$BANNER${RESET}" && echo -e "${YELLOW} > UPLOADING FIRMWARE NOW${RESET}" && echo " "
 #echo " > EXECUTING: ${UPLOAD_CMD[*]}"
 "${UPLOAD_CMD[@]}"
 cd $HOME
 #clear && echo -e "${GREEN}$BANNER${RESET}"
 #countdown
 ;;
  *)
 clear && echo -e "${GREEN}$BANNER${RESET}" && echo -e "${RED} > INVALID INPUT ${RESET}"
 countdown
 clear
 ;;
 esac
done
 
