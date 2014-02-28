#!/bin/sh
# Auther gukai(gukai@xinnet.com)
# We do not verify the parameter, dangerous !




# Determine whether the vm is exist.
# $1 is the ctid
CtExist(){
    vzlist $1 -a >/dev/null 2>&1 || return 1
    return 0
}


# Determine whether the vm system is online.
# $1 is the ctid
SystemOnline(){
    if vzctl exec2 $1 ifconfig >/dev/null 2>&1  ; then
        return 0
    else
        return 1
    fi
}


# Determine whether the vm system is online.
# $1 is the ctid
# $2 is the seconds delay。
SystemOnlineDelay(){
    local i=0
    while [[ $i -le $2 ]] && ! vzctl exec2 $1 ifconfig >/dev/null 2>&1 ; do
        #echo "try again $i"
        i=`expr $i + 1`
        sleep 1
    done

    if [[ $i -ge $2 ]] ; then
       return 1
    else
       return 0
    fi
}


VerfiyParameter(){
    local liststr=$1
    #echo $liststr
    local paralist=$(printf %s "$liststr" |tr ' ' '\n')

    for paraname in $paralist; do
        eval paravalue="$"$paraname
        #echo $paraname is $paravalue
        if [ -z $paravalue ]; then
            echo $paraname
            return 1
        fi
    done
  
    return 0  
}

MacToName(){
    local ctid=$1
    local srcmac=$2
    
    local configfile=/etc/vz/conf/${ctid}.conf
    echo $configfile
    . $configfile
    NETIFLIST=$(printf %s "$NETIF" |tr ';' '\n')
    #echo $NETIFLIST

    for iface in $NETIFLIST; do
        bridge=
        host_ifname=
        for str in $(printf %s "$iface" |tr ',' '\n'); do
            case "$str" in
                bridge=*|mac=*|ifname=*)
                    eval "${str%%=*}=\${str#*=}" 
                    echo $ifname " : " $mac
                    ;;
            esac
        done
        
#        if [[ $srcmac == $mac ]];then
#            echo $ifname
#            return 0
#        fi

    done
    echo "failed"    
    return 0

}



