#!/bin/bash
COMMAND=""
CTID=""
BRIDGE=""
DEVNAME=""
IPADDR=""
NETMASK=""
GATEWAY=""
DNS1=""
DNS2=""

all-usage(){
    create-veth-usage
    addbrif-usage
}

create-veth-usage() {
    echo "create usage: --command create <--ctid id>  <--bridge bridge>  <--devname name> <--ipaddr ip> <--netmask mask> <--gateway gateway> <--dns1 dns> [--dns2 dns]"
}

addbrif-usage(){
    echo "addbrif usage: --command addbrif <--ctid id>"    
}

net-init-usage(){
    echo "net-init usage: --command net-init"
}


is_online(){
    local i=0
    while [ $i -le 5 ] && ! vzctl exec2 $CTID ifconfig >/dev/null 2>&1 ; do
        #echo "try again $i"
        i=`expr $i + 1`
        sleep 1
    done

    if [ $i -ge  5 ] ; then
       return 1
    else
       return 0
    fi
}

validate-create() {
    
    if [  -e /etc/vz/vznet.conf ] ; then
        rm -f /etc/vz/vznet.conf
    fi

    if [ -z ${CTID} ];then
        echo "ERROR"
        echo "ctid must be set"
	exit 2;
    fi

    if [ -z ${BRIDGE} ];then
        echo "ERROR"
        echo "bridge must be set"
	exit 2;
    fi

    if [ -z ${DEVNAME} ];then
        echo "ERROR"
        echo "devname must be set"
	exit 2;
    fi

    if [ -z ${IPADDR} ];then
        echo "ERROR"
        echo "ipaddr must be set"
	exit 2;
    fi

    if [ -z ${NETMASK} ];then
        echo "ERROR"
        echo "netmask must be set"
	exit 2;
    fi
    if [ -z ${GATEWAY} ];then
        echo "ERROR"
        echo "gateway must be set"
	exit 2;
    fi
    if [ -z ${DNS1} ];then
        echo "ERROR"
        echo "dns1 must be set"
	exit 2;
    fi
    
    #echo "command:$COMMAND, ctid:$CTID, bridge:$BRIDGE, devname:$DEVNAME, ipaddr:$IPADDR, netmask:$NETMASK, gateway:$GATEWAY, dns1:$DNS1"
}

validate-addbrif(){
    if [ -z ${CTID} ];then
        echo "ERROR"
        echo "ctid must be set"
        exit 2;
    fi
 
    if ! is_online; then
       echo "ERROR"
       echo "$CTID is offline"
       exit 4
    fi
}


create-veth(){
    if ! vzlist $CTID -a >/dev/null 2>&1; then
        echo "ERROR"
        echo "The CTID is not exist."
	exit 3
    fi 
    
    validate-create  
 
    if is_online; then
        add-netconfig
    else
       echo "ERROR"
       echo "$CTID is offline"
       exit 4
    fi
    
    local num=`echo $DEVNAME | grep -Eo '[0-9]+'`

    vzctl set $CTID --netif_add $DEVNAME --bridge $BRIDGE --ifname $DEVNAME --save >/dev/null 2>&1
    
    brctl addif $BRIDGE veth$CTID.$num >/dev/null 2>&1
    
    vzctl exec $CTID ifup $DEVNAME >/dev/null 2>&1
    echo "SUCCESS"
        
}

add-netconfig(){
    if [ -z ${DNS2} ]; then
        local conf="TYPE=Ethernet NM_CONTROLLED=no BOOTPROTO=static ONBOOT=yes DEVICE=$DEVNAME IPADDR=$IPADDR NETMASK=$NETMASK GATEWAY=$GATEWAY DNS1=$DNS1"
    else
        local conf="TYPE=Ethernet NM_CONTROLLED=no BOOTPROTO=static ONBOOT=yes DEVICE=$DEVNAME IPADDR=$IPADDR NETMASK=$NETMASK GATEWAY=$GATEWAY DNS1=$DNS1 DNS2=$DNS2"
    fi
    vzctl exec2 $CTID "echo $conf > /etc/sysconfig/network-scripts/ifcfg-$DEVNAME" >/dev/null 2>&1
}

addbrif(){
    CONFIGFILE=/etc/vz/conf/${CTID}.conf
    . $CONFIGFILE

    NETIFLIST=$(printf %s "$NETIF" |tr ';' '\n')
    #echo $NETIFLIST

    for iface in $NETIFLIST; do
        bridge=
        host_ifname=

        for str in $(printf %s "$iface" |tr ',' '\n'); do
            case "$str" in
                bridge=*|host_ifname=*|ifname=*)
                    eval "${str%%=*}=\${str#*=}" ;;
            esac
        done
        
        num=`echo $ifname | grep -Eo '[0-9]+'`

        if [ -n $bridge ] ; then
            brctl addif $bridge veth$CTID.$num >/dev/null 2>&1
        fi
    done
    echo "SUCCESS"
}

net-init(){
    runninglist=`vzlist -o ctid -H 2>/dev/null`
    #echo $runninglist
    for line in $runninglist; do
      CTID=$line
      addbrif
    done
    echo "SUCCESS"
}


#Main from here

which brctl > /dev/null 2>&1
if [ $? != 0 ]; then
    echo "ERROR"
    echo "It's necessary  to install  bridge-utils"
    exit 5
fi

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
exit $?
