#!/bin/sh
. ./xinvz-vzctlerr.sh
. ./xinvz-lib.sh

CTID=""
BKDIR=""



usage(){
    echo "display the usage."
    echo "$0 --command bk_full <--ctid id> <--bkdir dir>"
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

ctexist(){
    local CTID=$1

    if ! CtExist ${CTID};then
        echo "ERROR"
        echo "The CTID is not exist"
        exit 1
    fi
}

bkfull(){

    #echo "make the full backup."
    local paralist="CTID BKDIR"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi
    
    ctexist $CTID

   
    local id=$(uuidgen)
    local private_path=$(vzlist -H -o private $CTID)
    local BKPATH=${BKDIR}/$CTID-$( date +%F_%H_%M )
    mkdir -p $BKPATH
    

    if [ ! -d ${private_path}/root.hdd/ ]; then
        echo "ERROR"
        echo "The VM $CTID disk type is not ploop, we do not support other now."
        exit 1
    fi

    # Take a snapshot without suspending a CT and saving its config
    vzctl snapshot $CTID --id $id --skip-suspend --skip-config > /dev/null 2>&1
    vzctlinfo $?

    # Perform a backup using your favorite backup tool
    # (cp is just an example)
    cp ${private_path}/root.hdd/* $BKPATH/
    
    #FIX ME
    #compress or not？

    # Delete (merge) the snapshot
    vzctl snapshot-delete $CTID --id $id > /dev/null 2>&1
    vzctlinfo $? "exit"

    echo "SUCCESS"  
}

bkincrement(){
    echo "make the increment backup."
}

delete(){
   echo "delete the special bakcup."
}






TEMP=`getopt -o m:c:d: --long command:,ctid:,bkdir: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -m| --command) COMMAND=$2 ; shift 2 ;;
                -c|--ctid) CTID=$2; shift 2 ;;
                -d|--bkdir) BKDIR=$2; shift 2 ;;
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
    bk_full) bkfull ;;
    bk_increment) bkincrement ;;
    delete) delete ;;
    usage) usage ;;
    * ) usage ;;
esac
