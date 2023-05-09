#!/bin/bash -x

# Import any other variable files if you want
source ./vars/vars.sh
source ./vars/colors.sh
# source ./prod/vars.sh
# source ./prod/colors.sh


# Loop through the VM IDs and execute the qm start command
for vmID in "${vmIDs[@]}"
do
    echo -e "____________________"
    echo -e "Starting VM $vmID..."
    echo -e "--------------------"
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
	    if [ "$vm_status" == "stopped" ]; then
		    COLOR=$RED
	    elif [ "$vm_status" == "running" ]; then
		    COLOR=$GREEN
	    else
		    COLOR=$NC
	    fi
	    echo -e "${COLOR}-=VM $vmID $vm_status. =-${NC}"
	    echo -e "__VM IP ${BLUE}${vmIPs["$vmID"]}${NC} could not be reached__"
            read -p "Do you want to retry or continue? [retry/continue]" choice
            case $choice in
                [Rr] | [Rr]etry )
                    echo -e "Retrying VM startup for ${BLUE}$vmID${NC}"
                    qm start $vmID
                    ping_timeout=30
                    break
                    ;;
                [Cc] | [Cc]ontinue )
                    echo -e "Continuing with next VM..."
                    break
                    ;;
                * )
                    echo -e "Invalid choice. Please enter 'retry' or 'continue'."
                    ;;
            esac
	done
    fi
    
    # Generate a report showing the status of each VM
    if $vm_up
    then
        echo -e "VM $vmID ${GREEN}started${NC}"
    else
        echo -e "${RED}VM ${BLUE}$vmID${NC} encountered issues.${NC}"
    fi
done

qm_list=$(qm list)
echo "${qm_list%%$'\n'*}"

for vmid in "${vmIDs[@]}"; do
    echo "$qm_list" | grep -E "^ *$vmid "
done
