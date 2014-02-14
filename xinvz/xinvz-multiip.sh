#!/bin/bash
id=""

usage-usage(){
    echo "xinvz-multiip.sh <--devname name> <--ipaddr ip> <--netmask mask>"
}

add_network(){
    checketh=`ls /etc/sysconfig/network-scripts/ifcfg-${DEVNAME} 2>/dev/null`
    if [ -z "$checketh" ]
    then
        echo "No Physical Interface ${DEVNAME} configuration file found! Exiting...!"
        exit 3;
    else
        max=`ls /etc/sysconfig/network-scripts/ |grep ${DEVNAME} |awk -F: '{print $2}'|sort -n |tail -1`
        if [ "$max" == "" ]
        then
            id=0
        else
            id=$[$max+1]
        fi
        echo "DEVICE=${DEVNAME}:${id}
              ONBOOT=yes
              BOTOPROTO=no
              IPADDR=${IPADDR}
              NETMASK=${NETMASK} ">/etc/sysconfig/network-scripts/ifcfg-${DEVNAME}:$id
              ifup $DEVNAME:$id
    fi

    echo "$?"
}


TEMP=`getopt -o d:i:n: --long devname:,ipaddr:,netmask: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -d|--devname) DEVNAME=$2 ; shift 2 ;;
                -i|--ipaddr) IPADDR=$2 ; shift 2 ;;
                -n|--netmask) NETMASK=$2 ; shift 2 ;;
                --) shift ; break ;;
                *) echo "Unknow Option, verfiy your command" ; usage-usage; exit 1 ;;
        esac
done

if [ -z ${DEVNAME} ];then
    echo "ERROR"
    echo "Paramater devname must be set."
    exit 1
fi 
if [ -z ${IPADDR} ];then
    echo "ERROR"
    echo "Paramater ipaddr must be set."
    exit 1
fi 
if [ -z ${NETMASK} ];then
    echo "ERROR"
    echo "Parameter netmask must be set."
    exit 1
fi

add_network
