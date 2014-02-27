#!/bin/bash
# usage: limit interface bandwidth
# m(k)bps = m(k) bytes per second
# m(k)bit = m(k) bit per second
# normal downlink grater than uplink

. ./xinvz-lib.sh


validate(){
    if ! CtExist ${CTID};then
        echo "ERROR"
        echo "The CTID is not exist"
    fi


}


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
