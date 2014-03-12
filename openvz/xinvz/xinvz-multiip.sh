#!/bin/bash
id=""

usage-usage(){
    echo "xinvz-multiip.sh <--devname name> <--ipaddr ip> <--netmask mask>"
}

system_online(){
    if vzctl exec2 $CTID ifconfig >/dev/null 2>&1  ; then
        return 0
    else
        return 1
    fi
}

add_network(){
    checketh=`vzctl exec $CTID ls /etc/sysconfig/network-scripts/ifcfg-${DEVNAME} 2>/dev/null`
    #echo $checketh
    if [ -z "$checketh" ];then
        echo "ERROR"
        echo "No Physical Interface ${DEVNAME} configuration file found! Exiting...!"
        exit 3;
    else
        max=`vzctl exec $CTID ls /etc/sysconfig/network-scripts/ |grep ${DEVNAME} |awk -F: '{print $2}'|sort -n |tail -1`
        #echo "max is " $max
        if [ "$max" == "" ];then
            id=0
        else
            id=$[$max+1]
        fi
        config="DEVICE=${DEVNAME}:${id} ONBOOT=yes BOTOPROTO=no IPADDR=${IPADDR} NETMASK=${NETMASK}"
        #echo $config
        #echo "ifcfg-${DEVNAME}:$id"
        #echo "$config > /etc/sysconfig/network-scripts/ifcfg-${DEVNAME}:$id"

        vzctl exec $CTID "echo $config > /etc/sysconfig/network-scripts/ifcfg-${DEVNAME}:$id"
        #vzctl exec $CTID echo "DEVICE=${DEVNAME}:${id}
        #      ONBOOT=yes
        #      BOTOPROTO=no
        #      IPADDR=${IPADDR}
        #      NETMASK=${NETMASK} ">/etc/sysconfig/network-scripts/ifcfg-${DEVNAME}:$id
        vzctl exec $CTID ifup $DEVNAME:$id
    fi

    return 0
}


TEMP=`getopt -o c:d:i:n: --long ctid:,devname:,ipaddr:,netmask: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -c|--ctid) CTID=$2; shift 2 ;;
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
if [ -z ${CTID} ];then
    echo "ERROR"
    echo "Parameter ctid must be set."
    exit 1
fi

if ! system_online; then
    echo "ERROR"
    echo "VM is not online or exist."
    exit 1
fi

#test
#echo "DEVNAME is " $DEVNAME
#echo "CTID is " $CTID
#echo "IPADDR is " $IPADDR
#echo "NETMASK is " $NETMASK

add_network
echo "SUCCESS"
