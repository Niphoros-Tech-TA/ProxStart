#!/bin/bash

source ./colors.sh
source ./vars.sh

#########################################################
# VM IDs that needs to be gotten from Proxmox
# Check either the Proxmox UI or by running 'qm list'
#########################################################
vmIDs=(
100 #Ansible Server
104 #Ubuntu Server
105 #CentOS WebServer
)
# Define the ping timeout in seconds
# Depending on the boot time, you can reduce it as you see fit

ping_timeout=30

# Define an associative array of VM IP addresses
# This is similar to a dictionary in Python
declare -A vmIPs
vmIPs=(
["100"]="10.0.0.100" 
["104"]="10.0.0.103" 
["105"]="192.168.0.1"
)

# Loop through the VM IDs and execute the qm start command
for vmID in "${vmIDs[@]}"
do
    echo "____________________"
    echo -e "Starting VM $vmID..."
    echo "--------------------"
    qm start $vmID &> /dev/null
    
    # Wait for the VM to start up and respond to pings
    vm_up=false
    while [ $ping_timeout -gt 0 ]
    do
        if ping -c 1 -W 1 ${vmIPs["$vmID"]} &> /dev/null
        then
            vm_up=true
	    vm_status=$(qm status $vmID)
            break
        fi
        sleep 1
        ping_timeout=$(( $ping_timeout - 1 ))
    done
    
    # If the VM has not responded to pings, ask the user if they want to retry or continue
    if ! $vm_up
    then
        while true; do
	    $vm_status
	    if [ "$vm_status" == "stopped" ]; then
		    COLOR=$RED
	    elif ["$vm_status" == "running" ]; then
		    COLOR=$GREEN
	    else
		    COLOR=$RESET
	    fi
	    echo "${COLOR}-=VM $vmID $vm_status. =-${RESET}"
	    echo "__VM IP ${vmIPs["$vmID"]} could not be reached__"
            read -p "Do you want to retry or continue? [retry/continue]" choice
            case $choice in
                [Rr] | [Rr]etry )
                    echo "Retrying VM startup for $vmID"
                    qm start $vmID
                    ping_timeout=30
                    break
                    ;;
                [Cc] | [Cc]ontinue )
                    echo "Continuing with next VM..."
                    break
                    ;;
                * )
                    echo "Invalid choice. Please enter 'retry' or 'continue'."
                    ;;
            esac
	done
    fi
    
    # Generate a report showing the status of each VM
    if $vm_up
    then
        echo "VM $vmID ${GREEN}started${RESET}"
    else
        echo "VM $vmID ${RED} encountered issues.${RESET}"
    fi
done

qm_list=$(qm list)
echo "${qm_list%%$'\n'*}"

for vmid in "${vmIDs[@]}"; do
    echo "$qm_list" | grep -E "^ *$vmid "
done
