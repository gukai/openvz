#!/bin/sh
CPUUSAGE=0
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

  
cpu_record(){
    local log_record=$(vzctl exec $CTID cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
    local id_record=$(vzctl exec $CTID echo $log_record | awk '{print $4}')
    local total_record=$(echo $log_record | awk '{print $1+$2+$3+$4+$5+$6+$7}')
    local used_record=`expr $total_record - $id_record`
    echo ${total_record},${used_record}
}

cpu_used(){
    # CPUUSAGE=`vzctl exec2 $CTID top -n 1 | grep 'Cpu(s)' | awk '{print $5}' | cut -d'%' -f1`
    date1=`cpu_record`
    sleep 1
    date2=`cpu_record`

    total1=`echo $date1 | awk -F "," '{print $1}'`
    total2=`echo $date2 | awk -F "," '{print $1}'`
    used1=`echo $date1 | awk -F "," '{print $2}'`
    used2=`echo $date2 | awk -F "," '{print $2}'`

    total=`expr $total2 - $total1`
    used=`expr $used2 - $used1`

    #example
    #awk 'BEGIN{printf "%.2f%\n",'$num1'/'$num2'}'
    #awk 'BEGIN{printf "%.0f\n", ('$used'/'$total')*100}' | read CPUUSAGE
    CPUUSAGE=`awk 'BEGIN{printf "%.0f\n", ('$used'/'$total')*100}'`
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

