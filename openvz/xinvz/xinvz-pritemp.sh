#!/bin/sh
. ./xinvz-vzctlerr.sh
. ./xinvz-lib.sh

CTID=""
TEMPPATH=""
TEMPNAME=""

usage(){
    echo "$0 --command create <--ctid id> <--temppath path> <--tempname name>"
}

vzctlinfo(){
    local erro=$1
    local flag=$2
    if [ $erro -ne 0 ]; then
        echo "ERROR"
        eval echo "Error num " $erro ": "\${xinvzerr$erro}
        if [ "$flag" == "exit" ]; then
            exit 1
        fi
    fi
}


create(){

    local paralist="CTID TEMPPATH TEMPNAME"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    # Known snapshot ID
    local id=$(uuidgen)
    local erro

    # Directory used to mount a snapshot
    local mntdir=/var/run/xinvz/${CTID}/mktemp/
    mkdir -p $mntdir
 
    # Take a snapshot without suspending a CT and saving its config
    vzctl snapshot $CTID --id $id --skip-suspend --skip-config > /dev/null 2>&1
    vzctlinfo $? "exit"
 
    # Mount the snapshot taken
    vzctl snapshot-mount $CTID --id $id --target $mntdir > /dev/null 2>&1
    vzctlinfo $? 
 
    # Perform a backup using your favorite backup tool
    # (tar is just an example)
    tar -zcf ${TEMPPATH}/${TEMPNAME}.tar.gz -C $mntdir . >/dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR"
        echo "Some error occored when compressing the tmeplate"
    fi
 
    # Unmount the snapshot
    vzctl snapshot-umount $CTID --id $id  >/dev/null
    vzctlinfo $? "exit"
 
    # Delete (merge) the snapshot
    vzctl snapshot-delete $CTID --id $id  >/dev/null
    vzctlinfo $? "exit"

    echo "SUCCESS"
}



TEMP=`getopt -o c:i:p:n: --long command:,ctid:,temppath:,tempname: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -c|--command) COMMAND=$2; shift 2 ;;
                -i|--ctid) CTID=$2; shift 2 ;;
                -d|--temppath) TEMPPATH=$2; shift 2 ;;
                -i|--tempname) TEMPNAME=$2 ; shift 2 ;;
                --) shift ; break ;;
                *) echo "Unknow Option, verfiy your command" ; usage; exit 1 ;;
        esac
done

if [ -z ${COMMAND} ];then
    echo "ERROR"
    echo "command cant be null"
    exit 1
fi

case $COMMAND in
    create) create ;;
    usage) usage ;;
    *) usage ;;
esac
