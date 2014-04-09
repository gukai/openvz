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

#makesure the ctid is exist.
CurSnapshotId(){
    local ctid=$1
    ret=`vzctl snapshot-list $ctid -o current,id -H | grep ^* | awk '{print $2}' | cut -d '{' -f 2 | cut -d '}' -f1 2>/dev/null`
    echo $ret
}
#CurSnapshotId 301

#echo the unset parameter name and return 1 if have some parameter unset.
VerfiyParameter(){
    local liststr=$1
    #echo $liststr
    local paralist=$(printf %s "$liststr" |tr ' ' '\n')

    for paraname in $paralist; do
        eval paravalue="$"$paraname
        #echo $paraname is $paravalue
        if [ -z "$paravalue" ]; then
            echo $paraname
            return 1
        fi
    done
  
    return 0  
}

#NAME: By leaving src and srcvalue to find the vaule of dest in interface section of config file.
#SYNOPSIS: IfaceInfoFind <ctid> <src> <srcvalue> <dest>
#RETURN:
#   0: return 0 if success, echo the answer.
#   1: return 1 if ctid is not exist, echo the error info.
#   3: return 3 if src is not exist in config or is not match, echo the error info
#   4: return 4 if dest is not exist in config, echo the error info.
#PARAMETER:
#   ctid: the vm id which you search info.
#   src: the name of unique info you know about the ifaceinfo.
#   srcvaule: the value of src.
#   dest: the name of ifaceinfo we want to know.
#ifaceinfo in config: ifname/mac/host_ifname/host_mac/bridge
#BUG: make sure the config file is exist, and check it before.
IfaceInfoFind(){
    local ctid=$1
    local src=$2
    local srcvaule=$3
    local dest=$4
    CONFIGFILE=/etc/vz/conf/${ctid}.conf
    if [ ! -f $CONFIGFILE ]; then
        echo "the vm config file is not exist."
        return 1
    fi
    . $CONFIGFILE

    NETIFLIST=$(printf %s "$NETIF" |tr ';' '\n')
    #the all config line.
    #echo $NETIFLIST

    for iface in $NETIFLIST; do
        #complete interface info(ifname,host_ifname,bridge,and so on.)
        #echo $iface

        local ifname=""
        local mac=""
        local host_ifname=""
        local host_mac=""
        local bridge=""

        for str in $(printf %s "$iface" |tr ',' '\n'); do
            # every info str in one iface.
            # echo $str

            # info name.
            local infoname=`echo $str | cut -d'=' -f1`
            # info value
            local infovalue=`echo $str | cut -d'=' -f2`
            #echo "$infoname : $infovalue"

            #set the value.
            eval ${infoname}=${infovalue}
        done

        #get the src and dest vaule by search
        eval local srcfind="\${$src}"
        eval local destfind="\${$dest}"
        #echo $srcfind

        if [ "$srcfind" = "$srcvaule" ]; then
            if [ -z $destfind ]; then
                echo "if dest is not exist in config, echo the error info."
                return 4
            fi
            echo $destfind
            return 0
        fi
    done
    
    echo "src is not exist in config or not match."
    return 3
        
}


# $1 is the paralist which want to modify from the sedfile($2)
# sedfile must be the full path.
# return the cmd string.
# make sure the $2 is not null, or it will block here.
# the parameter needed in template must like that: <parameter="">
MakeScript(){
    local paralist=$1
    local sedfile=$2
    local rescpath=$3
    local cmd="sed"

    for para in $paralist; do
      #eval echo "$"$para
      local paravalue=`eval echo "$"$para`
      local srcstr=`echo "$para=\"\""`
      local deststr=`echo "$para=\"$paravalue\""`

      cmd="$cmd -e '/$srcstr/c $deststr'"
      #echo $cmd
    done
  
    cmd="$cmd $sedfile > $rescpath"
    eval $cmd
}
#test
#CTID=200
#COMMENT="new"
#MakeScript "CTID COMMENT" "./template" "./gukai"
