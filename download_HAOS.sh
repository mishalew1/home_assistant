#!/bin/bash
YELLOW="\e[38;5;227m"
ORANGE="\e[38;5;208m"
RED="\e[38;5;196m"
PINK="\e[38;5;206m"
GREEN="\e[38;5;77m"
BLUE="\e[38;5;4m"
WHITE="\e[38;5;255m"
GREY="\e[38;5;247m"
RESTORE="\e[0m"


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
        curl -sSLO $FILE_URL
	ls -lhA $FILE
    else
        ls -lhA --color=auto $DECOMPRESSED_FILE
    fi

}


decompress_downloaded_disk(){
    echo -e "\n${GREEN}${FUNCNAME}${RESTORE}"

    if [[ -f $FILE ]]; then
        xz --verbose --decompress $FILE
    fi
}


main(){
    query_latest_version
    download_haos
    decompress_downloaded_disk
}
main

    
