#!/bin/sh
. ./xinvz-lib.sh

# the default intranet card in VM is eth0.
INNIC=eth0

usage(){
    echo "./xinvz-isolate --command create <--srcctid ctid> <--ipaddr ip>"
    echo "        --srcctid: the ctid which vm you initialise"
    echo "        --ipaddr: the intranet card(default eth0) ip in datebase."
    echo "./xinvz-isolate --command addguest <srcctid ctid> <--ipaddr ip> "
    echo "        --srcctid: the ctid which vm you operate"
    echo "        --ipaddr: the opposite vm intranet card(default eth0) ip in datebase."
    echo "./xinvz-isolate --command delguest <srcctid ctid> <--ipaddr ip> "
    echo "        --srcctid: the ctid which vm you operate"
    echo "        --ipaddr: the opposite vm intranet card(default eth0) ip in datebase."
    echo "./xinvz-isolate --command destroy <--srcctid ctid>"
    echo "        --srcctid: the ctid which vm you destroy"
    echo "./xinvz-isolate --command usage"
    exit 0
}

create(){

    local paralist="SRCCTID IPADDR"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    # get mac by ifname
    if ! ret=`IfaceInfoFind $SRCCTID ifname $INNIC mac`; then
        echo "ERROR"
        echo $ret
        exit 1
    fi
    local srcmac=$ret

    # get host_ifname by ifname
    if ! ret=`IfaceInfoFind $SRCCTID ifname $INNIC host_ifname`; then
        echo "ERROR"
        echo $ret
        exit 1
    fi
    local brsubif=$ret

    ./xinvz-ebtables.sh init $brsubif $IPADDR $srcmac > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SUCCESS"
        exit 0
    else
       echo "ERROR"
       echo "ebtables init error."
       exit 1
    fi
         
}

addguest(){
    local paralist="SRCCTID IPADDR"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    #get src host_ifname by ifname
    if ! ret=`IfaceInfoFind $SRCCTID ifname $INNIC host_ifname`; then
        echo "ERROR"
        echo $ret
        exit 1
    fi
    local brsubif=$ret
    
    ./xinvz-ebtables.sh add-guest $brsubif $IPADDR > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SUCCESS"
        exit 0
    else
       echo "ERROR"
       echo "ebtables init error."
       exit 1
    fi  
    
}

delguest(){
    local paralist="SRCCTID IPADDR"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    #get src host_ifname by ifname
    if ! ret=`IfaceInfoFind $SRCCTID ifname $INNIC host_ifname`; then
        echo "ERROR"
        echo $ret
        exit 1
    fi
    local brsubif=$ret
    
    ./xinvz-ebtables.sh del-guest $brsubif $IPADDR > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SUCCESS"
        exit 0
    else
       echo "ERROR"
       echo "ebtables init error."
       exit 1
    fi   
}

destroy(){
    local paralist="SRCCTID"
    if ! ret=`VerfiyParameter "$paralist"`; then
        echo "ERROR"
        echo "Parameter $ret is not set."
        exit 1
    fi

    #get src host_ifname by ifname
    if ! ret=`IfaceInfoFind $SRCCTID ifname $INNIC host_ifname`; then
        echo "ERROR"
        echo $ret
        exit 1
    fi
    local brsubif=$ret

    ./xinvz-ebtables.sh del $brsubif $IPADDR > /dev/null 2>&1 
    if [ $? -eq 0 ]; then
        echo "SUCCESS"
        exit 0
    else
       echo "ERROR"
       echo "ebtables init error."
       exit 1
    fi   
}



TEMP=`getopt -o m:c:d:i: --long command:,srcctid:,destctid:,ipaddr: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
		-m| --command) COMMAND=$2 ; shift 2 ;;
                -c|--srcctid) SRCCTID=$2; shift 2 ;;
                -d|--destctid) DESTCTID=$2; shift 2 ;;
                -i|--ipaddr) IPADDR=$2 ; shift 2 ;;
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
    create) create ;;
    addguest) addguest ;;
    delguest) delguest ;;
    destroy) destroy ;;
    usage) usage ;;
esac

echo "ERROR"
echo "Unknow error"
exit 1
