#!/bin/bash
source ./prod/vars.sh &> /dev/null
source ./prod/colors.sh &> /dev/null

# The function iterates through each element in the vmIDs array

vmReport () {
    for vmID in "${vmIDs[@]}"
    do
        declare -Ag vmReportIDs
        vm_status=$(qm status $vmID)
        # This variable will check the status, but remove the 'status' at the beginning of the output
        vmSimpleStatus=$(qm status $vmID | sed 's/status: //')
        vmReportIDs[$vmID]="$vmSimpleStatus"
        # The if else statement checks the status of each ID.
        if [[ "$vm_status" == "status: running" ]]; then
            echo -e "- VM ${BLUE}$vmID${NC} with IP ${YELLOW}${vmIPs["$vmID"]}${NC} has the ${GREEN}$vm_status${NC}."

        elif [[ "$vm_status" == "status: stopped" ]]; then
            echo -e "- VM ${BLUE}$vmID${NC} with IP ${YELLOW}${vmIPs["$vmID"]}${NC} has the ${RED}$vm_status${NC}."
        fi
    done

    # The if statement checks to see if the variables from ./vars/vars.sh
    # 'vmReportTop' and 'vmReportBot' exists
    # And if present, it deletes them, and the text between them 
    if grep -q "^$vmReportTop" "$varFile" && grep -q "^$vmReportBot" "$varFile"; then
        sed -i "/^$vmReportTop/,/^$vmReportBot/d" "$varFile" &> /dev/null
    fi

    # Append new variables
    echo -e "$vmReportTop" >> "$varFile"
    sleep 1
    echo "$(declare -p  vmReportIDs| sed 's/declare -A/declare -Ag/')" >> $varFile
    sleep 1
    echo "$vmReportBot" >> "$varFile"

}
