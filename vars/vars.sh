#########################################################
# VM IDs that needs to be gotten from Proxmox
# Check either the Proxmox UI or by running 'qm list'
#########################################################
vmIDs=(
100 #Ansible Server
104 #Ubuntu Server
105 #CentOS WebServer
)

#########################################################
# Define an associative array of VM IP addresses
# This is similar to a dictionary in Python
########################################################
declare -A vmIPs
vmIPs=(
["100"]="10.0.0.10" 
["104"]="10.0.0.13" 
["105"]="192.168.0.1"
)

vmReportTop="###########VM Report Top#####################"
vmReportBot="###########VM Report Bot#####################"
varFile="/path/to/file"