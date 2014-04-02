#!/bin/sh
#Server will use this script to {create|attach|detach} keys.
#Client use the command to connect the Server. (ssh -i prikey usr@hostname) 
. ./xinvz-lib.sh

KeyDir="/root/.ssh/"
PKeyPath="/root/.ssh/authorized_keys"
PUBKEY=""
COMMENT=""
TYPE=""
PRIFILE=""
CTID=""

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

scriptname(){
    local seconds=`date +%s`
    scppath="sshkey-${seconds}-${COMMAND}.sh"
    mkdir -p /var/run/xinvz
    echo "/var/run/xinvz/${scppath}"
}


create(){
   local pridir=`dirname $PRIFILE`
   #echo $pridir

   if [ ! -d $pridir ]; then
        mkdir -p $pridir
   fi

   rm -f ${PRIFILE}
   rm -f ${PRIFILE}.pub

   ssh-keygen -q -t $TYPE -N "" -C $COMMENT -f $PRIFILE > /dev/null 2>&1
   echo "SUCCESS"   

}

detach(){
    local scpname=`scriptname`
    MakeScript "COMMAND COMMENT" "./template/xinvz-sshkey-temp" $scpname
    
    vzctl runscript $CTID $scpname 
    rm $scpname
    echo "SUCCESS"
}

attach(){
    local scpname=`scriptname`
    MakeScript "COMMAND PUBKEY" "./template/xinvz-sshkey-temp" $scpname
    
    vzctl runscript $CTID $scpname 
    rm $scpname
}


TEMP=`getopt -o m:i:c:t:y:p: --long command:,ctid:,pubkey:,comment:,type:,prifile:, \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -m| --command) COMMAND=$2 ; shift 2 ;;
                -i| --ctid) CTID=$2 ; shift 2 ;;
                -c|--pubkey) PUBKEY=$2; shift 2 ;;
                -t|--comment) COMMENT=$2; shift 2 ;;
                -y|--type) TYPE=$2; shift 2 ;;
                -p|--prifile) PRIFILE=$2; shift 2 ;;
                --) shift ; break ;;
                *) echo "Unknow Option, verfiy your command" ; usage; exit 1 ;;
        esac
done

if [ -z "${COMMAND}" ];then
    echo "ERROR"
    echo "$0: the command is null"
    exit 1
fi


case $COMMAND in
    attach)
        if ! ret=`VerfiyParameter "CTID PUBKEY"`; then
              echo "ERROR"
              echo "$ret is not set"
              exit 1
        fi 
        attach "$PUBKEY" 
        ;;
    detach) 
       if ! ret=`VerfiyParameter "CTID COMMENT"`; then
              echo "ERROR"
              echo "$ret not set"
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

echo "SUCCESS"
