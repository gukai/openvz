#!/bin/sh
. ./xinvz-vzctlerr.sh

cmd=$1
eval $cmd >/dev/null 2>&1
erro=$?
if [ $erro -eq 0 ]; then
    echo "SUCCESS"
else
    echo "ERROR"
    eval echo "Error num " $erro ": "\${xinvzerr$erro}
fi

#print all errno info
#while [ $erro -le 170 ]; do
#    eval echo "Error num " $erro ": "\${xinvzerr$erro}
#    erro=`expr $erro + 1`
#done

