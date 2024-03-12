#!/bin/bash

# Variables
# Text colors
GREEN="\e[38;5;77m"
RESTORE="\e[0m"

# VM Variables
RAM=2048
CPU_CORES=2
CPU_SOCKETS=1

# Find the next available VM ID
NEXT_ID=$(pvesh get /cluster/nextid)

# Use the next available VM ID or set VM_ID manually to preferred value
VM_ID=$NEXT_ID

VM_NAME=home-assistant
NETWORK=virtio,bridge=vmbr0

# The name of the storage pool you want to use
# I happen to use my ISO storage pool for VMs as well
STORAGE_LOCATION=ISO


query_latest_version(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    # URL with the latest releases
    URL=https://github.com/home-assistant/operating-system/releases/latest
    
    # Parse download URL
    DL_URL=$(curl -sI $URL | awk '/location/ {print $NF}')
    
    # Strip carriage return \r line ending that creates issues
    DL_URL=${DL_URL/[$'\r']}

    # Replace tag with download in URL
    DL_URL=${DL_URL/tag/download}

    # Get version from latest URL
    VERSION=${DL_URL##*/}

    # Create file name with latest $VERSION
    FILE="haos_ova-${VERSION}.qcow2.xz"

    # File comes compressed in xz, decompressed file name
    DECOMPRESSED_FILE=${FILE%%.xz}
    
    # Exact URL where file gets downloaded  from
    FILE_URL="${DL_URL}"/"${FILE}"

    echo -e "Latest version: $VERSION"
}


download_haos(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    if [[ ! -f $DECOMPRESSED_FILE ]]; then
        echo -e "Downloading $FILE_URL\n"
        #curl -sSLO $FILE_URL
        wget --quiet --show-progrss $FILE_URL
	ls -lhA $FILE
    fi
}


check_vm_id_available(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    if qm list | grep -wq "$VM_ID"; then
	    echo VM ID: $VIM_ID already exists
	    exit
    fi
}


create_vm(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    qm create $VM_ID \
        --name $VM_NAME \
        --bios ovmf \
        --ostype l26 \
        --memory $RAM \
        --cores $CPU_CORES \
        --sockets $CPU_SOCKETS \
        --scsihw virtio-scsi-single \
        --net0 $NETWORK \
        --efidisk0 $STORAGE_LOCATION:1,format=qcow2,efitype=4m,pre-enrolled-keys=0
    
    # Automatic start if proxmox reboots
    qm set $VM_ID -onboot 1
}


import_haos_disk(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    HAOS_DISK=/root/$DECOMPRESSED_FILE

    # Import HAOS disk to scsi0
    qm set $VM_ID --scsi0 $STORAGE_LOCATION:0,import-from=$HAOS_DISK

    # Set VM BIOS to boot from this disc on scsi0
    qm set $VM_ID --boot order='scsi0;net0'
}


start_hassos_vm(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    qm start $VM_ID
}


main(){
    query_latest_version
    download_haos
    decompress_downloaded_disk
    check_vm_id_available
    create_vm
    import_haos_disk
    start_hassos_vm
}
main
