#!/bin/sh
#Author: gukai(gukai@xinnet.com)
#version 0.2

. ./xinvz-vzctlerr.sh
. ./xinvz-lib.sh

CTID=""
BKDIR=""
BKFILE=""
SNAPSHOTID=""
FLAG=""

usage(){
    echo "$0 --command bk_full <--ctid id> <--bkdir dir>"
    echo "$0 --command bk_increment <--ctid id> <--bkdir dir> <--bkfile file>"
    echo "$0 --command bk_rollback <--ctid id> <--bkdir dir> <--bkfile filename> <--snapshotid id> [--flag force]" 
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

mktreact(){
    local bkdir=$1
    local bkfile=$2
    local actfile=${bkdir}/Active

    if [ ! -f ${actfile} ]; then
        touch ${actfile}
    fi

    echo $bkfile > ${actfile}

}

vefrtreact(){
    local bkdir=$1
    local bkfile=$2
    local actfile=${bkdir}/${bkfile}/Active

    local inbkfile=`sed -n '1 p' ${actfile}`

    if [ "$inbkfile" == "$bkfile" ]; then
        return 0
    fi

    return 1
}

havethesnap(){
    local diskxml=$1
    local snapid=$2
  
    ploop snapshot-list $1 -H -o uuid | grep $2 > /dev/null
 
    return $?
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
    local bkfile=$CTID-$( date +%F_%H_%M )
    local bkpath=${BKDIR}/$bkfile
    mkdir -p $bkpath
    

    if [ ! -d ${private_path}/root.hdd/ ]; then
        echo "ERROR"
        echo "The VM $CTID disk type is not ploop, we do not support other now."
        exit 1
    fi

    #Merge all snapshots down to base delta
    ploop snapshot-merge -A ${private_path}/root.hdd/DiskDescriptor.xml
    rm ${private_path}/Snapshots.xml 

    # Take a snapshot without suspending a CT and saving its config
    vzctl snapshot $CTID --id $id --skip-suspend --skip-config > /dev/null 2>&1
    vzctlinfo $?

    # Perform a backup using your favorite backup tool
    # (cp is just an example)
    cp -rp ${private_path}/root.hdd  $bkpath/
    
    # back the Snapshot depended.
    cp -fp ${private_path}/Snapshots.xml $bkpath/

    #FIX ME
    #compress or not？

    #do not delete the snapshot to hold the point to rollback.
    #Delete (merge) the snapshot
    #vzctl snapshot-delete $CTID --id $id > /dev/null 2>&1
    #vzctlinfo $? "exit"

    mktreact $BKDIR $bkfile

    echo "SUCCESS"
    echo "id: $id"
    echo "bkfile: $bkfile"
}

bkincrement(){
    local paralist="CTID BKDIR BKFILE"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    ctexist $CTID

    local id=$(uuidgen)
    local private_path=$(vzlist -H -o private $CTID)
    local bkpath=${BKDIR}/${BKFILE}

    if [ ! -d ${bkpath} ]; then
        echo "ERROR"
        echo "the backfile your specified is not in the parameter bkdir."
        exit 1
    fi

    if [ ! -d ${private_path}/root.hdd/ ]; then
        echo "ERROR"
        echo "The VM $CTID disk type is not ploop, we do not support other now."
        exit 1
    fi

    if ! vefrtreact $BKDIR $BKFILE ; then
        echo "ERROR"
        echo "The tree you specified is not active."
    fi

    # Take a snapshot without suspending a CT and saving its config
    vzctl snapshot $CTID --id $id --skip-suspend --skip-config > /dev/null 2>&1
    vzctlinfo $?

    local snapimg=`GetSnapshotImage ${private_path}/root.hdd/DiskDescriptor.xml $id`
    #echo $snapimg
    cp -fp ${private_path}/root.hdd/${snapimg}  $bkpath/root.hdd/    
    cp -fp ${private_path}/root.hdd/DiskDescriptor.xml $bkpath/root.hdd/

    cp -fp ${private_path}/Snapshots.xml $bkpath/

    echo "SUCCESS"
    echo "id $id"    
}

bkrollback(){

    #test before rollback.
    local paralist="CTID BKDIR BKFILE"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    #just line bkdir/bkfile
    local vm_private_path=$(vzlist -H -o private $CTID)
    local vm_snapdepend_file="${vm_private_path}/Snapshots.xml"
    local vm_disk_dir="${vm_private_path}/root.hdd"
    local vm_diskxml_file="${vm_disk_path/root.hdd/DiskDescriptor.xml}"
    local bk_active_file="${BKDIR}/ACTIVE"
    local bk_snapdepend_file="${BKDIR}/${BKFILE}/Snapshots.xml"
    local bk_disk_dir="${BKDIR}/${BKFILE}/root.hdd"
    local bk_diskxml_file="${bk_disk_dir}/DiskDescriptor.xml"


    local actre=`sed -n '1 p' ${bk_active_file}`
    if [ "$actre" != "$BKFILE" ]; then
        FLAG="force"
    fi

    if [ ! -d ${bk_disk_dir} ]; then
        echo "ERROR"
        echo "The Backup file is not exist."
        exit 1
    fi

    if [ ! -d ${vm_disk_dir} ]; then
        echo "ERROR"
        echo "The VM $CTID disk type is not ploop, we do not support other now."
        exit 1
    fi

    ctexist $CTID

    havethesnap ${bk_diskxml_file} $SNAPSHOTID
    if [ "$?" -nq "0" ];then
        echo "ERROR"
        echo "The $CTID snapshotid $SNAPSHOTID is not in bkfile $BKFILE."
        exit 1
    fi


    #Begin to rollback.
    if [ "$FLAG" == "force" ]; then
        SystemOnline $CTID
        local vm_status=$?

        if [ "$vm_status" -eq 0 ]; then
            #vzctl stop $CTID > /dev/null 2>&1
            echo "ERROR"
            echo "The VM $CTID must SHUTDOWN when you restore on other tree or with force flag."
            exit 1
        fi

        rm -rf ${vm_disk_dir}/*
        rm -f ${vm_snapdepend_file}

        cp -fp ${bk_disk_dir}/* ${vm_disk_dir}/
        cp -fp ${bk_snapdepend_file} ${vm_snapdepend_file}
    fi

    #delete by marsgu, the increacement disk  will be deleted when switch, vzctl delete will merge into the fater disk.
    #local id=`CurSnapshotId $CTID`
    #vzctl snapshot-delete $CTID --id $id > /dev/null 2>&1
    #vzctlinfo $? "exit"

    #really switch
    vzctl snapshot-switch $CTID $SNAPSHOTID 

    echo "SUCCESS"    
}

delete(){
   echo "delete the special bakcup."
}


TEMP=`getopt -o m:c:d:f:s:g --long command:,ctid:,bkdir:,bkfile:,snapshotid:,flag: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -m| --command) COMMAND=$2 ; shift 2 ;;
                -c|--ctid) CTID=$2; shift 2 ;;
                -d|--bkdir) BKDIR=${2%/}; shift 2 ;;
                -f|--bkfile) BKFILE=$2; shift 2 ;;
                -s|--snapshotid) SNAPSHOTID=$2; shift 2 ;;
                -g|--flag) FLAG=$2; shift 2 ;;
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
    bk_rollback) bkrollback ;;
    delete) delete ;;
    usage) usage ;;
    * ) usage ;;
esac
