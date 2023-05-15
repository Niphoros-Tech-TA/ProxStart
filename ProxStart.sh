#!/bin/bash

# Import any other variable files if you want
# source ./vars/vars.sh
# source ./vars/colors.sh
source ./prod/vars.sh
source ./prod/colors.sh
source ./modules/vmReport.sh

# Lists all your VMs based on the ./vars/vars.sh file
echo -e "-------------------------------------"
echo -e "${UPURPLE}This is the current status of your VMs${NC}"
echo -e "-------------------------------------"

# This will create a list with all the information provided in the ./vars/vars.sh file
# It creates 2 associative arrays for IDs and IPs 
# More details on the modules
vmReport

# After VM report, it will read the .vars/vars.sh file
while IFS= read -r line; 
do
    echo "Processing: $line" &> /dev/null
done <$varFile
sleep 1

echo -e "${BPURPLE}=====================================${NC}"
echo -e "${BPURPLE}=====================================${NC}"
# This iterates through the array resulted from vmReport function
for RID in "${!vmReportIDs[@]}"
do
    vmCheckStatus=$(qm status $RID)
    if [ "${vmReportIDs[$RID]}" == "running" ]; then
        # The nc utility is used for checking IP connections
        if ! nc -z -w 1 ${vmIPs["$RID"]} 22 &> /dev/null ;then
            echo -e "- For VM ${BLUE}$RID${NC} the IP address ${YELLOW}${vmIPs["$RID"]}${NC} ${RED}could not be reached${NC}.${UNDERLINE}Please check your VM IP${NC}"

        elif nc -z -w 1 ${vmIPs["$RID"]} 22 &> /dev/null ; then
            echo -e "- VM ${BLUE}$RID${NC} IP ${vmIPs[$RID]} ${GREEN}reached${NC} the target VM"
        fi
        echo -e "${BPURPLE}-------------------------------------${NC}"
    elif [ "${vmReportIDs[$RID]}" == "stopped" ]; then
        while retry=true;
        do
            read -p "$(echo -e "- VM ${BLUE}$RID${NC} is stopped. Do you want to ${GREEN}[Ss]${NC}tart the VM or ${RED}[Cc]${NC}ontinue without it?")" retryChoice
            case $retryChoice in 
                [Ss] | [Ss]tart )
                    
                    while [[ "$vmCheckStatus" == "status: stopped" ]];
                    do
                        vmCheckStatus=$(qm status $RID)
                        echo -e "${UNDERLINE}Starting VM${BLUE} $RID${NC}...${NC}"
                        qm start $RID &>/dev/null

                        if [[ "$vmCheckStatus" == "status: running" ]]; then
                            echo -e "VM started${GREEN}succesfully${NC}"
                            echo -e "${BPURPLE}-------------------------------------${NC}"
                        fi
                    done
                    break
                ;;
                
                [Cc] | [Cc]ontinue )
                    echo -e "VM $RID has ${RED}not started${NC}"
                    echo -e "${BPURPLE}-------------------------------------${NC}"
                    retry=true
                break
                ;;

                * )
                ;;
            esac
        done
    fi
done

echo -e "-------------------------------------"
echo -e "${UPURPLE}VM status after running the script${NC}"
echo -e "-------------------------------------"

vmReport