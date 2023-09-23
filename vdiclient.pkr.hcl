

# Resource Definiation for the VM
source "proxmox-iso" "vdiclient" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = "${var.proxmox_node_name}"
    vm_id = "802" # if not specified, use the next available id
    vm_name = "vdiclient-template"
    template_description = "vdiclient Image"

    # VM OS Settings
    # Download ISO
    iso_url = "${var.iso_url}"
    iso_checksum = "${var.iso_checksum}"
    iso_storage_pool = "local"
    unmount_iso = true

    # VM System Settings

    # VM Hard Disk Settings

    # VM CPU Settings

    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # PACKER Boot Commands
    boot_command = [
    "root<enter><wait>",
    "ifconfig 'eth0' up && udhcpc -i 'eth0'<enter><wait5s>",
    "setup-alpine -q<enter><wait5s>",
    # Select keyboard layout.
    "gb<enter><wait>",
    # Select keyboard Variant.
    "gb-mac_intl<enter><wait>",
    # Setup Timezone
    "setup-timezone -z UTC<enter><wait5s>",
    # Enable community repository.
    "sed -i -e '/community$/ s/#//' /etc/apk/repositories<enter><wait5s>",
    # Update apk
    "apk update<enter><wait5s>",
    # Setup the X11 server for graphics
    "setup-xorg-base<enter><wait15s>",
    # Install packaged for a basic kiosk
    "apk add openbox xterm terminus-font font-noto <enter><wait10s>",
    # Create non priviledged [non root] user
    "adduser vdi <enter><wait5s><enter><wait5s><enter><wait5s>",
    # Add vdi user to the input group
    "addgroup vdi input<enter><wait>",
    # Add vdi user to the video group
    "addgroup vdi video<enter><wait5s>",

    # Step 2 Install the PVE-VDIClient
    # Install dependency packages to create the Broker interface
    "apk add py3-pip python3-tkinter py3-pyside2 virt-viewer git<enter><wait35s>",
    # Logout the root user
    "exit<enter><wait5s>",
    # Login as VDI user
    "vdi<enter><wait5s><enter><wait5s>",
    # Install the Python dependency packages
    "pip3 install proxmoxer<enter><wait5s>",
    "pip3 install PySimpleGUI<enter><wait5s>",
    "pip3 install requests<enter><wait15s>",
    # Clone the Repo
    "git clone https://github.com/joshpatten/PVE-VDIClient.git<enter><wait10s>",
    # Make the VDIClient Executable
    "chmod -x ~/PVE-VDIClient/vdi.py<enter><wait5s>",
    # create the config directory
    "mkdir -p ~/.config/VDIClient<enter><wait5s>",
    # copy the example config file
    "cp ~/PVE-VDIClient/vdiclient.ini.example ~/.config/vdiclient.ini<enter><wait5s>",
    # amend the config file
    # the example ip address from the config
    "sed -i '/10.10.10.100 = 8006/s/^/#/' ~/.config/VDIClient/vdiclient.ini<enter><wait5s>",
    # add hostname
    "sed -i 's/pve1.example.com/${var.proxmox_node_name}.${var.proxmox_node_domain}/g' ~/.config/VDIClient/vdiclient.ini<enter><wait5s>",

    #Configure Openbox
    "echo 'exec startx' >> ~/.profile<enter><wait5s>",
    "echo 'exec openbox-session' >> ~/.xinitrc<enter><wait5s>",
    "cp -r /etc/xdg/openbox ~/.config<enter><wait5s>",
    # remove autostart file
    "rm ~/.config/openbox/autostart<enter><wait5s>",
    # create new autostart file
    "echo '#!/bin/sh' > ~/.config/openbox/autostart<enter><wait5s>",
    "echo 'while true' >> ~/.config/openbox/autostart<enter><wait5s>",
    "echo 'do' >> ~/.config/openbox/autostart<enter><wait5s>",
    "echo '    python ~/PVE-VDIClient/vdiclient.py' >> ~/.config/openbox/autostart<enter><wait5s>",
    "echo 'done' >> ~/.config/openbox/autostart<enter><wait5s>",
    # Log out the VDI user
    "exit<enter><wait5s>",
    #
    # make vdi autostart on boot
    #
    # login as root user
    "root<enter><wait5s>",
    # update inittab to log the vdi user in
    "sed -i 's#tty1::respawn:/sbin/getty 38400 tty1#tty1::respawn:/bin/login -f vdi#' /etc/inittab<enter><wait5s>",
    # Remove the .ash_history from vdi so our command history isn’t visible to anyone
    "rm -f /home/vdi/.ash_history<enter><wait5s>",
    # Remove the packages we installed but only needed for setup so they aren’t usable in the final system
    "apk del git xterm nano<enter><wait10s>",
    # include /home in the lbu package
    "lbu include /home<enter><wait5s>",
    # package the system using lbu
    "lbu package thinclient.apkovl.tar.gz<enter><wait5s>",
    #
    # Option 1 - Copy APKOVL to Netboot Server
    # "apk add busybox-extras<enter><wait5s>",
    # "ip a<enter><wait5s>",
    # "busybox-extras httpd -f -v<enter>",
    # Option 2 - Copy file to NFS File share
    "apk add nfs-utils<enter><wait10s>",
    "mkdir -p /mnt/nfs<enter><wait5s>",
    "mount -t nfs -o nolock,nfsvers=3,proto=tcp ${var.nfs_folder} /mnt/nfs<enter><wait>",
    "cp thinclient.apkovl.tar.gz /mnt/nfs/<enter><wait5s>",
    "umount /mnt/nfs<enter><wait>",
    "apk del nfs-utils<enter><wait10s>",
    "poweroff<enter>",
    ]
    boot = "c"
    boot_wait = "10s"

    ssh_username = "${var.ssh_username}"

    # (Option 1) Add your Password here
    ssh_password = "ubuntu"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    # ssh_private_key_file = "~/.ssh/id_rsa"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"

}

build {
    sources = ["source.proxmox-iso.vdiclient"]
}