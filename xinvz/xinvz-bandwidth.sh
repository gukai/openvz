#!/bin/bash
# usage: limit interface bandwidth
# m(k)bps = m(k) bytes per second
# m(k)bit = m(k) bit per second
# normal downlink grater than uplink

. ./xinvz-lib.sh
CTID=""
TIMEOUT=""
DEVNAME=""
DOWNLINK=""
UPLINKLINK=""


validate(){
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


exec-limit(){
    DEV=$1
    DOWNLINK=$2mbit
    UPLINK=$3mbit
    burst=1m

    # clean existing down- and uplink qdiscs, hide errors
    /sbin/tc qdisc del dev $DEV root 2> /dev/null > /dev/null
    /sbin/tc qdisc del dev $DEV ingress 2> /dev/null > /dev/null

    # uplink
    # install root HTB, point default traffic to 1::
    /sbin/tc qdisc add dev $DEV root handle 1: htb default 1
    /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate ${UPLINK} ceil ${UPLINK} burst ${burst}

    # downlink
    /sbin/tc qdisc add dev $DEV handle ffff: ingress
    /sbin/tc filter add dev $DEV parent ffff: protocol ip prio 50 u32 match ip src 0.0.0.0/0 police rate ${DOWNLINK} burst ${burst} drop flowid :1

    # show uplink qdisc and class detail 
    /sbin/tc -s qdisc show dev $DEV
    /sbin/tc -s class show dev $DEV
    /sbin/tc filter ls dev $DEV parent ffff:

    echo $?
}

limit-test(){
    local paralist="CTID DEVNAME DOWNLINK UPLINK"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi
}



TEMP=`getopt -o m:c:d:x:s --long command:,ctid:,devname:,downlink:,uplink: \
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
    limit) limit-test ;;
    show) show-limit;;
    usage) usage ;;
esac
