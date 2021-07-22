#!/bin/bash

while true
do
 read -r -p "Want to update and upgrade system? [Y/n] " input
 case $input in
     [yY][eE][sS]|[yY])
 echo "Yes"
 break
 ;;
     [nN][oO]|[nN])
 echo "No"
 break 
        ;;
      *)
 echo "Invalid input..."
 ;;
 esac
done
