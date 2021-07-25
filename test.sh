#!/bin/bash

# prints the name of the script
#echo $0

# prints the absolute path of the script 
full_path=$(realpath $0)
#echo $full_path

# prints teh dir of the script
SCRIPT_DIR=$(dirname $full_path)
#echo $SCRIPT_DIR

$HOME/bin/yq e '.BINARY.LOCATION' $SCRIPT_DIR/settings.yaml 
