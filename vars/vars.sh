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
# Define the ping timeout in seconds
# Depending on the boot time, you can reduce it as you see fit
########################################################

ping_timeout=5

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