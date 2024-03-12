# Home Assistant Scripts

## These scripts automate the installation of Home Assistant on Proxmox

### install_home_assistant.sh
This script does the following:
- query github.com/home-assistant for the latest VERSION
- download the latest OVA VM disk which comes compressed in xz
- decompress the disk using the xz command
- create a VM in proxmox with the following:
    - 2 CPU
    - 2GB RAM
    - OVMF Bios (UEFI)
    - secure boot disabled (required)
    - reboot when proxmox reboots or loses power
- imports the decompressed DISK to the VM
- changes the boot order to boot from this VM Disk
- start the proxmox VM
