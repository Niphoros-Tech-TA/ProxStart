#!/bin/bash

# Import any other variable files if you want
# source ./vars/vars.sh
# source ./vars/colors.sh
source ./prod/vars.sh
source ./prod/colors.sh
source ./modules/vmReport.sh

# Lists all your VMs based on the ./vars/vars.sh file
echo -e "${BPURPLE}--------------------------------------${NC}"
echo -e "This is the current status of your VMs"
echo -e "${BPURPLE}--------------------------------------${NC}"

# This will create a list with all the information provided in the ./vars/vars.sh file
# It creates 2 associative arrays for IDs and IPs 
# More details on the modules
vmReport

# In order for *vmCheck* to have the updated version of the vmReport file, it needs to re-read again
while IFS= read -r line; 
do
    echo "Processing: $line" &> /dev/null
done <$varFile
sleep 1

echo -e "${BPURPLE}======================================${NC}"
for RID in "${!vmReportIDs[@]}"
do
    vmCheckStatus=$(qm status $RID)
    if [ "${vmReportIDs[$RID]}" == "running" ]; then
        if ! [ ping -c 1 -W 1 ${vmIPs[$RID]} &> /dev/null ] ; then
            echo -e "- For VM $RID the IP address ${YELLOW}${vmIPs["$RID"]}${NC} ${RED}could not be reached${NC}.${UNDERLINE}Please check your VM IP${NC}"

        elif [ ping -c 1 -W 1 ${vmIPs[$RID]} &> /dev/null ] ; then
            echo -e "VM IP ${vmIPs["$RID"]} reached the target VM"
        fi
        echo -e "${BPURPLE}-------------------------------------${NC}"
    elif [ "${vmReportIDs[$RID]}" == "stopped" ]; then
        while retry=true
        do
            read -p "$(echo -e "VM is stopped. Do you want to ${GREEN}[Ss]${NC}tart the VM or ${RED}[Cc]${NC}ontinue without it?")" retryChoice
            case $retryChoice in 
                [Ss] | [Ss]tart )
                    vmCheckStatus=$(qm status $RID)
                    if [[ "$vmCheckStatus" == "status: running" ]]; then
                        echo "VM has ${GREEN}started${NC}"
                        retry=true
                    elif [[ "$vmCheckStatus" == "status: stopped" ]]; then
                        qm start $RID
                        echo -e "${UNDERLINE}Starting VM $RID again...${NC}"
                        retry=false
                    fi
                break
                ;;
                
                [Cc] | [Cc]ontinue )
                echo -e "VM $RID has ${RED}not started${NC}"
                retry=true
                break
                ;;

                * )
                ;;
            esac
        done
    fi
done

echo -e "${BPURPLE}-------------------------------------${NC}"
echo -e "VM status after running the script"
echo -e "${BPURPLE}-------------------------------------${NC}"

vmReport