//  variables.pkr.hcl

// Your Proxmox Server's IP Address
// https://${IPADDRESS}:${PORT}/api2/json
variable "proxmox_api_url" {
    type =  string
}

variable "proxmox_api_token_id" {
    type =  string
    // Sensitive vars are hidden from output as of Packer v1.6.5
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type =  string
    // Sensitive vars are hidden from output as of Packer v1.6.5
    sensitive = true
}

variable "proxmox_node_name" {
    type =  string
}

variable "proxmox_node_domain" {
    type = string
}

variable "iso_url" {
    type = string
    default = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
}

variable "iso_checksum" {
    type = string
    default = "a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
}

variable "ssh_username" {
    type = string
}