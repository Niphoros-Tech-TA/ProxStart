
# Introduction

This is a script that I created in order to start a set of VMs. 
Mainly this was done for automatically starting Kubernetes-related VMs or Ansible testing.

# Getting started

1. Clone the repo
	- `git clone https://github.com/Niphoros-Tech-TA/ProxStart`
2. Make sure your files have execution permissions
	- `chmod +x ./vars/vars.sh`
	- `chmod +x ./vars/colors.sh`
	- `chmod +x ./vars/vars.sh`
	- `chmod +x ./ProxStart.sh`
3. Collect your Proxmox VM IDs and IPs beforehand
	- This can be found on your Proxmox Web UI or via the command line
		- `qm list` will show the VMs that you want to add to your script
4. Add them to the `./vars/vars.sh` file