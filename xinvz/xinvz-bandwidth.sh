#!/bin/bash
# usage: limit interface bandwidth
# m(k)bps = m(k) bytes per second
# m(k)bit = m(k) bit per second
# normal downlink grater than uplink

. ./xinvz-lib.sh
CTID=""      
TIMEOUT=""



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



TEMP=`getopt -o m:c:b:d:i:n:g:s:z: --long command:,ctid:,bridge:,devname:,ipaddr:,netmask:,gateway:,dns1:,dns2: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -m| --command) COMMAND=$2 ; shift 2 ;;
                -c|--ctid) CTID=$2; shift 2 ;;
                -b|--bridge) BRIDGE=$2 ; shift 2 ;;
                -c|--devname) DEVNAME=$2 ; shift 2 ;;
                -i|--ipaddr) IPADDR=$2 ; shift 2 ;;
                -n|--netmask) NETMASK=$2 ; shift 2 ;;
                -g|--gateway) GATEWAY=$2; shift 2 ;;
                -s|--dns1) DNS1=$2; shift 2 ;;
                -z|--dns2) DNS2=$2; shift 2 ;;
                --) shift ; break ;;
                *) echo "Unknow Option, verfiy your command" ; usage-usage; exit 1 ;;
        esac
done

if [ -z ${COMMAND} ];then
    echo "ERROR"
    echo "command cant be null"
    exit 1
fi

case $COMMAND in
    create) create-veth ;;
    net-init) net-init;;
    usage) all-usage ;;
    addbrif) addbrif;;
esac
