#!/bin/bash
source ./prod/vars.sh &> /dev/null
source ./prod/colors.sh &> /dev/null
source ./modules/vmReport.sh &> /dev/null


vmCheck () {
    for RID in "${!vmReportIDs[@]}"
    do
        vmCheckStatus=$(qm status $RID)
        if [ "${vmReportIDs[$RID]}" == "running" ]; then
            if ! [ ping -c 1 -W 1 ${vmIPs[$RID]} &> /dev/null ] ; then
                echo -e "VM $RID is in $vmCheckStatus"
                echo -e "VM IP ${vmIPs["$RID"]} could not be reached.Please check your VM IP"

            elif [ ping -c 1 -W 1 ${vmIPs[$RID]} &> /dev/null ] ; then
                echo -e "VM $RID is in $vmCheckStatus"
                echo -e "VM IP ${vmIPs["$RID"]} reached the target VM"
            fi
        elif [ "${vmReportIDs[$RID]}" == "stopped" ]; then
            echo -e "VM $RID is in $vmCheckStatus"
            while retry=true
            do
                read -p "VM is stopped. Do you want to [Rr]etry or [Cc]ontinue?" retryChoice
                case $retryChoice in 
                    [Rr] | [Rr]etry )
                        vmCheckStatus=$(qm status $RID)
                        if [[ "$vmCheckStatus" == "status: running" ]]; then
                            echo "VM has started"
                            retry=true
                        elif [[ "$vmCheckStatus" == "status: stopped" ]]; then
                            qm start $RID
                            echo -e "Starting VM $RID again..."
                            retry=false
                        fi
                    break
                    ;;
                    
                    [Cc] | [Cc]ontinue )
                    echo -e "VM $RID hasn't started yet"
                    retry=true
                    break
                    ;;

                    * )
                    ;;
                esac
            done
        fi
    done

}

vmStart () {
    vm_status=$(qm status $RID)
    vm_start=$(qm start $RID)
    # vmIP=${vmIPs["$vmID"]}
    if [[ "$vmCheckStatus" == "status: running" ]]; then
        $vm_start
    elif [[ "$vmCheckStatus" == "status: stopped" ]]; then
        $vm_status
    fi
}