#!/bin/sh
. ./xinvz-vzctlerr.sh

startvm(){
    if [ -z ${CTID} ];then
        echo "ERROR"
        echo "the ctid must be specified when this script try to start vm."
    fi

    vzctl start ${CTID} >/dev/null 2>&1
    local ret=$?
    
    if [ $ret == 0 -o $ret == 32 ];then
        if system_online_delay;then
            echo "SUCCESS"
        else
            echo "ERROR"
            echo "VM Power is on, system boot up timeout."
        fi
    else
        echo "ERROR"
	eval echo "Error num " $erro ": "\${xinvzerr$ret}
    fi

}

system_online(){
    if vzctl exec2 $CTID ifconfig >/dev/null 2>&1  ; then
        return 0
    else
        return 1
    fi
}

system_online_delay(){
    local i=0
    while [ $i -le 100 ] && ! vzctl exec2 $CTID ifconfig >/dev/null 2>&1 ; do
        #echo "try again $i"
        i=`expr $i + 1`
        sleep 1
    done

    if [ $i -ge 100 ] ; then
       return 1
    else
       return 0
    fi
}



####MAIN#####
TEMP=`getopt -o m:c:b:d:i:n:g:s:z: --long command:,ctid:,bridge:,devname:,ipaddr:,netmask:,gateway:,dns1:,dns2: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "ERROR" >&2 ; exit 1 ; fi

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
    start) startvm ;;
    *) usage;;
esac
exit $?
