#!/bin/bash

# Import any other variable files if you want
# source ./vars/vars.sh
# source ./vars/colors.sh
source ./prod/vars.sh
source ./prod/colors.sh
source ./modules/vmReport.sh
source ./modules/vmStart.sh

# Lists all your VMs based on the ./vars/vars.sh file
echo -e "-------------------------------------"
echo -e "This is the current status of your VM"
echo -e "-------------------------------------"

vmReport

while IFS= read -r line; 
do
    echo "Processing: $line" &> /dev/null
done <$varFile
sleep 1

vmCheck
