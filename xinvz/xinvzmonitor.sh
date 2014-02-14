#!/bin/sh
PUUSAGE=0
TX_BYTES=0
RX_BYTES=0
DISK_READ=0
DISK_WRITE=0


usage(){
    echo 'xinvzmonitor.sh <CTID | all | all_online | usage>'
}

is_online(){
    if vzctl exec2 $CTID ifconfig >/dev/null 2>&1  ; then
        return 0
    else
        return 1
    fi
}

cpu_used(){
    local i=0
    local list=`vzctl exec $CTID vmstat 1 1 | awk '{if(NR==3)print $0;}'`
    #echo $list

    for c in $list; do
       i=`expr $i + 1`
       if [ $i -eq 15 ]; then id=$c; fi
    done

    CPUUSAGE=`expr 100 - $id`
}

net_flux(){
    vm_id=$CTID
    ex_nic=veth${vm_id}.1
    #echo $ex_nic
    TX_BYTES=`cat /sys/devices/virtual/net/${ex_nic}/statistics/tx_bytes 2>/dev/null`
    RX_BYTES=`cat /sys/devices/virtual/net/${ex_nic}/statistics/rx_bytes 2>/dev/null`

    #when some problem occured before, the value will be null.
    if [ -z $TX_BYTES ];then
        TX_BYTES=0
        RX_BYTES=0
    fi
}

mom_one(){
    if ! vzlist $CTID -a >/dev/null 2>&1; then
        echo "ERROR"
        echo "The CTID is not exist."
        exit 3
    fi

    if ! is_online; then
        #Must rest here, mom_all will call it muti times.
        CPUUSAGE=0
        TX_BYTES=0
        RX_BYTES=0
        DISK_READ=0
        DISK_WRITE=0
        #echo -e ${CTID}"\t" ${CPUUSAGE}"\t" ${RX_BYTES}"\t" ${TX_BYTES}"\t"
        echo -ne ${CTID}" "${CPUUSAGE}" "${RX_BYTES}" "${TX_BYTES}","
        return 0
    fi
    #echo "online"
    cpu_used
    net_flux
    #echo -e ${CTID}"\t" ${CPUUSAGE}"\t" ${RX_BYTES}"\t" ${TX_BYTES}"\t"
    echo -ne ${CTID}" "${CPUUSAGE}" "${RX_BYTES}" "${TX_BYTES}","
}

mom_all_online(){
    runninglist=`vzlist -o ctid -H 2>/dev/null`
    #echo $runninglist
    for line in $runninglist; do
      CTID=$line
      mom_one
    done
}

mom_all(){
    runninglist=`vzlist -a -o ctid -H | awk 'NR > 1 {print $1}' 2>/dev/null`
    #echo $runninglist
    for line in $runninglist; do
      CTID=$line
      mom_one
    done
    echo -ne "\n"
}

#Main from here
if [ $# -ne 1 ]; then
    usage
    exit 1
fi


case "$1" in
    all)
        mom_all
        ;;
    all_online)
        mom_all_online
        ;;
    usage)
        usage
        ;;
    *)
        CTID=$1
        mom_one
        ;;
esac
