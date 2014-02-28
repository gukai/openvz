#!/bin/sh
. ./xinvz-lib.sh

ctexist(){
    local CTID=$1

    if ! CtExist ${CTID};then
        echo "ERROR"
        echo "The CTID is not exist"
        exit 1
    fi
}
#ctexist $1 || exit 1


systemonlinedelay(){
    local CTID=$1
    local TIMEOUT=$2
    
    if ! SystemOnlineDelay ${CTID} ${TIMEOUT} ; then
        echo "ERROR"
        echo "The CT is not online"
        exit 1
    fi

}
#systemonlinedelay $1 $2 || exit 1


#testexample
hehe="zouzhe"
eee="shide"
sss="haode"
verfiyparameter(){
    local para=$1

    if ! ret=`VerfiyParameter "$para"`; then
        echo "ERROR"
        echo "Parameter $ret is Null."
    fi
}
verfiyparameter "hehe eee sss"



#other func in lib.
#SystemOnline $1
