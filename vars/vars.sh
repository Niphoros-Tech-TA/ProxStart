#########################################################
#Do not modify these unless you know what you are doing.
#########################################################
vmReportTop="###########VM Report Top#####################"
vmReportBot="###########VM Report Bot#####################"

#########################################################
# This is where you add your VM IDs
#########################################################
vmIDs=(
100 #Ansible Server
104 #Ubuntu Server
105 #CentOS WebServer
)

#########################################################
# This is where you add the IP associated to each VM
# ["VM ID"]="VM IP"
########################################################
declare -A vmIPs
vmIPs=(
["100"]="10.0.0.10" 
["104"]="10.0.0.13" 
["105"]="192.168.0.1"
)

#########################################################
# Modify it for the full path of your ./vars/vars.sh
# Example: /home/username/ProxStart/vars/vars.sh
#########################################################
varFile="/path/to/file"