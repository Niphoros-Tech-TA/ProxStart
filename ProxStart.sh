#!/bin/bash

# Import any other variable files if you want
# source ./vars/vars.sh
# source ./vars/colors.sh
source ./prod/vars.sh
source ./prod/colors.sh


# Loop through the VM IDs and execute the qm start command
for vmID in "${vmIDs[@]}"
do
    echo -e "____________________"
    echo -e "Starting VM $vmID..."
    echo -e "--------------------"
    
    # Wait for the VM to start up and respond to pings
    vm_up=false
    qm start $vmID &> /dev/null
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

    check_ping() {
        if ping -c 1 -W 1 ${vmIPs["$vmID"]} &> /dev/null
        then
            vm_up=true
        fi
    }

    # If the VM has not responded to pings, ask the user if they want to retry or continue
    if ! $vm_up && ! ping -c 1 -W 1 ${vmIPs["$vmID"]} &> /dev/null;
    then
        while true; do
            if ! ping -c 1 -W 1 ${vmIPs["$vmID"]} &> /dev/null; then
            # If ping test fails, then check the vm_status
                # if [[ "$vm_status" == "status: stopped" ]]; then
                # elif [[ "$vm_status" == "status: running" ]]; then
                # fi
            read -p "Do you want to retry or continue? [retry/continue]" choice
                case $choice in
                    [Rr] | [Rr]etry )
                        if [[ "$vm_status" == "status: stopped" ]]; then
                            echo -e "-=VM $vmID ${RED} $vm_status${NC}. =-"
                            echo -e "__VM IP ${BLUE}${vmIPs["$vmID"]}${NC} ${RED}could not be reached ${NC}__"
                            qm start $vmID &> /dev/null
                        elif [[ "$vm_status" == "status: running" ]]; then
                            echo -e "-=VM $vmID ${GREEN} $vm_status${NC}. =-"
                            echo -e "__VM IP ${BLUE}${vmIPs["$vmID"]}${NC} ${RED}could not be reached ${NC}__"
                            echo -e "Retrying VM startup for ${BLUE}$vmID${NC}"
                            check_ping
                            break
                        elif [ ping -c 1 -W 1 ${vmIPs["$vmID"]} &> /dev/null ]; then
                            echo -e "-=VM $vmID ${GREEN} $vm_status${NC}. =-"
                            echo -e "__VM IP ${BLUE}${vmIPs["$vmID"]}${NC} ${GREEN}pinged and received ${NC}__"
                        fi
                        ;;
                    [Cc] | [Cc]ontinue )
                        echo -e "Continuing with next VM..."
                        break
                        ;;
                    * )
                        echo -e "Invalid choice. Please enter 'retry' or 'continue'."
                        ;;
                esac
            fi
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
