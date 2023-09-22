# Proxmox VDI Client (feat. Alpine Linux) Packer Script

## Acknlowledgements
This project was inspired by "apalrd's adventures" Youtube video "Netbooted Proxmox VDI Client(https://www.youtube.com/watch?v=r-TnP06K-gE&t=653s)"

Thanks is extended to John Patten the creator of PVE-VDIClient and without his application (https://github.com/joshpatten/PVE-VDIClient), this project would not have been possible.

## Todo
Write the Packer script!

## Command Line
As at Sept 2023, I tried to follow the guides from John and Apalrd and ran into some problems. Below is how I got to a running configuration. In a future iteration of this repository I will aim to make a packer file to automate this installation.

## Setup VM in Proxmox

node = "your-node"
vm_id = "120"
vm_name = "vdiclient01"
template_description = "VDI Client"

iso_url = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.3-x86_64.iso"
iso_checksum = "badeb7f57634c22dbe947bd692712456f2daecd526c14270355be6ee5e73e83e"
iso_storage_pool = "local"
unmount_iso = true

No Disks

`# VM CPU Settings
cores = "2"

`# VM Memory Settings
memory = "3072" 

`# VM Network Settings
network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = "false"
} 

# PACKER Boot Commands
boot_command = [
    "root<enter><wait>",
    "ifconfig 'eth0' up && udhcpc -i 'eth0'<enter><wait5s>",
    "setup-alpine -q<enter><wait>",
    # Select keyboard layout.
    "gb<enter>",
    # Select keyboard Variant.
    "gb<enter>",
    # Setup Timezone
    "setup-timezone -z UTC<enter><wait>",
    # Enable community repository.
    "sed -i -e '/community$/ s/#//' /etc/apk/repositories<enter>",
    # Update apk
    "apk update<enter><wait5s>",
    # Setup the X11 server for graphics
    "setup-xorg-base<enter><wait15s>",
    # Install packaged for a basic kiosk
    "apk add openbox xterm terminus-font font-noto <enter><wait5s>".
    # Create non priviledged [non root] user
    "adduser vdi <enter><enter><enter>",
    # Add vdi user to the input group
    "addgroup vdi input<enter>",
    # Add vdi user to the video group
    "addgroup vdi video<enter>",
    #
    # Step 2 Install the PVE-VDIClient
    # Install dependency packages to create the Broker interface
    "apk add py3-pip python3-tkinter py3-pyside2 virt-viewer git",
    # Logout the root user
    "exit<enter>",
    # Login as VDI user
    "vdi<enter><enter>",
    # Install the Python dependency packages
    "pip3 install proxmoxer<enter>",
    "pip3 install PySimpleGUI<enter>",
    "pip3 install requests<enter>",
    # Clone the Repo
    "git clone https://github.com/joshpatten/PVE-VDIClient.git",
    # Make the VDIClient Executable
    "chmod -x ~/PVE-VDIClient/vdi.py"
    # create the config directory
    "mkdir -p ~/.config/VDIClient",
    # copy the example config file
    "cp ~/PVE-VDIClient/vdiclient.ini.example ~/.config/vdiclient.ini",
    # amend the config file
    # the example ip address from the config
    "sed -i '/10.10.10.100 = 8006/s/^/#/' ~/.config/VDIClient/vdiclient.ini",
    # add hostname
    "sed -i 's/pve1.example.com/highball001.hampshire.local/g' ~/.config/VDIClient/vdiclient.ini",

    #Configure Openbox
    "echo 'exec startx' >> ~/.profile",
    "echo 'exec openbox-session' >> ~/.xinitrc",
    "cp -r /etc/xdg/openbox ~/.config",
    # remove autostart file
    "rm ~/.config/openbox/autostart",
    # create new autostart file
    "echo '#!/bin/sh' > ~/.config/openbox/autostart",
    "echo 'while true' >> ~/.config/openbox/autostart",
    "echo 'do' >> ~/.config/openbox/autostart",
    "echo '    python ~/PVE-VDIClient/vdiclient.py' >> ~/.config/openbox/autostart",
    "echo 'done' >> ~/.config/openbox/autostart",
    "exit<enter>",
    #
    # make vdi autostart on boot
    #
    # login as root user
    "root<enter><enter>"
    # update inittab to log the vdi user in
    "sed -i 's#tty1::respawn:/sbin/getty 38400 tty1#tty1::respawn:/bin/login -f vdi#' /etc/inittab",
    # Remove the .ash_history from vdi so our command history isn’t visible to anyone
    "rm -f /home/vdi/.ash_history",
    # Remove the packages we installed but only needed for setup so they aren’t usable in the final system
    "apk del git xterm nano",
    # include /home in the lbu package
    "lbu include /home",
    # package the system using lbu
    "lbu package thinclient.apkovl.tar.gz",
    #
    #Copy APKOVL to Netboot Server
    #





]