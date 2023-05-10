#!/bin/bash

# Import any other variable files if you want
# source ./vars/vars.sh
# source ./vars/colors.sh
source ./prod/vars.sh
source ./prod/colors.sh

# Lists all your VMs based on the ./vars/vars.sh file
echo -e "-------------------------------------"
echo -e "This is the current status of your VM"

for vmID in "${vmIDs[@]}"
do
    vm_status=$(qm status $vmID)
    vm_ip=${vmIPs["$vmID"]}
    if [[ "$vm_status" == "status: running" ]]; then
    echo -e "VM ${BLUE}$vmID${NC} with IP ${YELLOW}$vm_ip${NC} has the ${GREEN}$vm_status${NC}."

    elif [[ "$vm_status" == "status: stopped" ]]; then
    echo -e "VM ${BLUE}$vmID${NC} with IP ${YELLOW}$vm_ip${NC} has the ${RED}$vm_status${NC}."
    fi
done