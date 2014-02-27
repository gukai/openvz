#!/bin/sh
. ./xinvz-lib.sh

ctexist(){
    local CTID=$1

    if ! CtExist ${CTID};then
        echo "ERROR"
        echo "The CTID is not exist"
        exit 1
    fi
}

systemonlinedelay(){
    local CTID=$1
    local TIMEOUT=$2
    
    if ! SystemOnlineDelay ${CTID} ${TIMEOUT} ; then
        echo "ERROR"
        echo "The CT is not online"
        exit 1
    fi

}
#ctexist $1 || exit 1
#systemonlinedelay $1 $2 || exit 1
#SystemOnline $1
