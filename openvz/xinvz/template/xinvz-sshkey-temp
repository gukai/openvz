#!/bin/sh
#Server will use this script to {create|attach|detach} keys.
#Client use the command to connect the Server. (ssh -i prikey usr@hostname) 

KeyDir="/root/.ssh/"
PKeyPath="/root/.ssh/authorized_keys"
PUBKEY=""
COMMENT=""
TYPE=""
PRIFILE=""

usage(){
    echo "$0 --command create <--type type>  <--comment comment> <--prifile prifilename>"
    echo "        --type: rsa1/rsa/dsa"
    echo "        --comment: the comment of the key"
    echo "        --prifile: the prikey path and filename. ie. /root/prikey/newkey"
    echo "$0 --command attach <--pubkey keystring>"
    echo "        --pubkey: the public key string which want to attach."
    echo "$0 --command detach <--comment comment>"
    echo "        --pubkey: the comment of the public key which want to detach.(it will datach all the key have the same comment)"
}

create(){
   local pridir=`dirname $PRIFILE`
   echo $pridir

   if [ ! -d $pridir ]; then
        mkdir -p $pridir
   fi

   rm -f ${PRIFILE}
   rm -f ${PRIFILE}.pub

   ssh-keygen -q -t $TYPE -N "" -C $COMMENT -f $PRIFILE > /dev/null 2>&1
}

detach(){

    if [ ! -e $PKeyPath ]; then
        echo "authorized_keys is not exist."
        exit 0
    fi

    local comment=$1
    local cmd="sed -i '/${comment}$/d' ${PKeyPath}"
    eval $cmd       
}

attach(){
    local pubkeystr=$1
    #echo $pubkeystr

    if [ ! -d $KeyDir ]; then
        mkdir -p $KeyDir
        chmod 700 $KeyDir
    fi

    if [ ! -e $PKeyPath ]; then
        touch $PKeyPath
        chmod 600 $PKeyPath
    fi
  
   echo $pubkeystr >> $PKeyPath
}

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



#dattach "$1"

TEMP=`getopt -o m:c:t:y:p: --long command:,pubkey:,comment:,type:,prifile:, \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -m| --command) COMMAND=$2 ; shift 2 ;;
                -c|--pubkey) PUBKEY=$2; shift 2 ;;
                -t|--comment) COMMENT=$2; shift 2 ;;
                -y|--type) TYPE=$2; shift 2 ;;
                -p|--prifile) PRIFILE=$2; shift 2 ;;
                --) shift ; break ;;
                *) echo "Unknow Option, verfiy your command" ; usage; exit 1 ;;
        esac
done

if [ -z "${COMMAND}" ];then
    echo "COMMAND IS NULL"
    exit 1
fi


case $COMMAND in
    attach)
        if ! ret=`VerfiyParameter "PUBKEY"`; then
              echo "PUBKEY not set"
              exit 1
        fi 
        attach "$PUBKEY" 
        ;;
    detach) 
       if ! ret=`VerfiyParameter "COMMENT"`; then
              echo "COMMENT not set"
              exit 1
       fi
       detach $COMMENT  
       ;;
    create) 
       if ! ret=`VerfiyParameter "COMMENT TYPE PRIFILE"`; then
           echo "$ret not set"
           exit 1
       fi
       create 
       ;;
    usage)
        usage
        ;;
    *)
        usage
       exit 2
       ;;
esac


