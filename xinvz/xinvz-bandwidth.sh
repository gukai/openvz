#!/bin/bash
# usage: limit interface bandwidth
# m(k)bps = m(k) bytes per second
# m(k)bit = m(k) bit per second
# normal downlink grater than uplink

. ./xinvz-lib.sh
TIMEOUT=1
CTID=""
DEVNAME=""
DOWNLINK=""
UPLINKLINK=""

usage(){
    usage-exec
    usage-show
    usage-usage
}

usage-exec(){
    echo "./xinvz-bandwidth.sh --command limit  <--devname dev> <--downlink num> <--uplink num> <--ctid ctid>  [--timeout time]"
    echo "        --ctid: the CT's id."
    echo "        --devname: the devname in CT."
    echo "        --downlink: the size of downlink bandwidth, the unit is mbit."
    echo "        --downlink: the size of uplink bandwidth, the unit is mbit."
    echo "        --timeout: command timeout. optional, the default value is 1"
    echo ""
}

usage-show(){
    echo "./xinvz-bandwidth.sh --command show <--ctid ctid> <--devname dev>"
    echo "        --ctid: the CT's id"
    echo "        --devname: the devname in CT"
    echo ""
}

usage-usage(){
    echo "./xinvz-bandwidth.sh --command usage"
    echo ""
}


validate(){

    local paralist="CTID DEVNAME DOWNLINK UPLINK"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    if ! CtExist ${CTID};then
        echo "ERROR"
        echo "The CTID is not exist"
        exit 1
    fi
   
    if ! SystemOnlineDelay ${CTID} ${TIMEOUT} ; then
        echo "ERROR"
        echo "The CT is not online"
        exit 1
    fi
}

show-limit(){

    local paralist="CTID DEVNAME"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    local num=`echo $DEVNAME | grep -Eo '[0-9]+'`
    local outdev=veth$CTID.$num

    # show uplink qdisc and class detail
    /sbin/tc -s qdisc show dev $outdev
    /sbin/tc -s class show dev $outdev
    /sbin/tc filter ls dev $outdev parent ffff:    
}


exec-limit(){
    validate
    local num=`echo $DEVNAME | grep -Eo '[0-9]+'`
    local outdev=veth$CTID.$num
    local downlink=${DOWNLINK}mbit
    local uplink=${UPLINK}mbit
    local burst=1m
    #echo $downlink $uplink $burst

    # clean existing down- and uplink qdiscs, hide errors
    /sbin/tc qdisc del dev $outdev root >/dev/null 2>&1
    /sbin/tc qdisc del dev $outdev ingress >/dev/null 2>&1
   
    # uplink
    # install root HTB, point default traffic to 1::
    /sbin/tc qdisc add dev $outdev root handle 1: htb default 1 >/dev/null 2>&1
    /sbin/tc class add dev $outdev parent 1: classid 1:1 htb rate ${uplink} ceil ${uplink} burst ${burst} >/dev/null 2>&1

    # downlink
    /sbin/tc qdisc add dev $outdev handle ffff: ingress >/dev/null 2>&1
    /sbin/tc filter add dev $outdev parent ffff: protocol ip prio 50 u32 match ip src 0.0.0.0/0 police rate ${downlink} burst ${burst} drop flowid :1 >/dev/null 2>&1

    echo "SUCCESS"
    return 0

}



TEMP=`getopt -o m:c:d:x:s:t --long command:,ctid:,devname:,downlink:,uplink:,timeout: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -m| --command) COMMAND=$2 ; shift 2 ;;
                -c|--ctid) CTID=$2; shift 2 ;;
                -c|--devname) DEVNAME=$2 ; shift 2 ;;
                -x|--downlink) DOWNLINK=$2 ; shift 2 ;;
                -n|--uplink) UPLINK=$2 ; shift 2 ;;
                -t|--timeout) TIMEOUT=$2 ; shift 2 ;;
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
    limit) exec-limit ;;
    show) show-limit;;
    usage) usage ;;
    *) usage ;;
esac

if ! [ $? -eq 0 ]; then
    echo "ERROR"
fi
