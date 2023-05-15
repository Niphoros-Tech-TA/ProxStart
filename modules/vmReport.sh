
#!/bin/bash
source ./prod/vars.sh &> /dev/null
source ./prod/colors.sh &> /dev/null

vmReport () {
    for vmID in "${vmIDs[@]}"
    do
        declare -Ag vmReportIDs
        vm_status=$(qm status $vmID)
        vmSimpleStatus=$(qm status $vmID | sed 's/status: //')
        # vmIP=${vmIPs["$vmID"]}
        vmReportIDs[$vmID]="$vmSimpleStatus"
        if [[ "$vm_status" == "status: running" ]]; then
            echo -e "- VM ${BLUE}$vmID${NC} with IP ${YELLOW}${vmIPs["$vmID"]}${NC} has the ${GREEN}$vm_status${NC}."

        elif [[ "$vm_status" == "status: stopped" ]]; then
            echo -e "- VM ${BLUE}$vmID${NC} with IP ${YELLOW}${vmIPs["$vmID"]}${NC} has the ${RED}$vm_status${NC}."
        fi
    done

    if grep -q "^$vmReportTop" "$varFile" && grep -q "^$vmReportBot" "$varFile"; then
        sed -i "/^$vmReportTop/,/^$vmReportBot/d" "$varFile" &> /dev/null
    fi

    # Append new content
    echo -e "$vmReportTop" >> "$varFile"
    sleep 1
    echo "$(declare -p  vmReportIDs| sed 's/declare -A/declare -Ag/')" >> $varFile
    sleep 1
    echo "$vmReportBot" >> "$varFile"

}
