# Proxmox VDI Client (feat. Alpine Linux) Packer Script

## Acknlowledgements
This project was inspired by "apalrd's adventures" Youtube video "Netbooted Proxmox VDI Client(https://www.youtube.com/watch?v=r-TnP06K-gE&t=653s)"

Thanks is extended to John Patten the creator of PVE-VDIClient and without his application (https://github.com/joshpatten/PVE-VDIClient), this project would not have been possible.

## Purpose
The purpose of this package is to use Packer with a Proxmox node to generate a 'thinclient.apkovl.tar.gz' onto a NFS fileshare. Once the file is on the fileshare, it can be copied to a netboot (iPXE) server to allow the VDI Client to be booted onto a ThinClient Hardware.

### User Variables

The following variable are dynamically inserted into the script from the variables.pkrvars.hcl (example in the repo)
1. proxmox_api_url - # Your Proxmox Node API URL
2. proxmox_api_token_id - API Token ID
3. proxmox_api_token_secret - API token secret
4. proxmox_node_name - Name of the Proxmox node
5. proxmox_node_domain - host domain
6. iso_url - URL for the Alpine Linux ISO file. 
7. iso_checksum - ISO file checksum
8. ssh_username - Not used currently
9. nfs_folder - The path to the nfs folder

### Run Command

At the Terminal run the following command`packer build -var-file="variables.pkrvars.hcl" .`

## Command Line
As at Sept 2023, I tried to follow the guides from John and Apalrd and ran into some problems. Below is how I got to a running configuration. In a future iteration of this repository I will aim to make a packer file to automate this installation.