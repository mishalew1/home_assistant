#!/bin/bash

# Find the next available VM ID
NEXT_ID=$(pvesh get /cluster/nextid)

# Use the next available VM ID or set VM_ID manually to preferred value
VM_ID=$NEXT_ID

RAM=2048
CPU_CORES=2
CPU_SOCKETS=1
NETWORK=virtio,bridge=vmbr0
HAOS_DISK=/root/haos_ova-12.0.qcow2
STORAGE_LOCATION=ISO


check_vm_id_available(){
    if qm list | grep -wq "$VM_ID"; then
	    echo VM ID: $VIM_ID already exists
	    exit
    fi
}


create_vm(){
    qm create $VM_ID \
        --name home-assisstant \
        --bios ovmf \
        --ostype l26 \
        --memory $RAM \
        --cores $CPU_CORES \
        --sockets $CPU_SOCKETS \
        --scsihw virtio-scsi-single \
        --net0 $NETWORK \
        --efidisk0 ISO:1,format=qcow2,efitype=4m,pre-enrolled-keys=0
    
    # Automatic start if proxmox reboots
    qm set $VM_ID -onboot 1
}


import_haos_disk(){
    # Import HAOS disk to scsi0
    qm set $VM_ID --scsi0 $STORAGE_LOCATION:0,import-from=$HAOS_DISK

    # Set VM BIOS to boot from this disc on scsi0
    qm set $VM_ID --boot order='scsi0;net0'
}


main(){
    check_vm_id_available
    create_vm
    import_haos_disk
}
main
