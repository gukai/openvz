#!/bin/sh

alllist=`vzlist --all -o ctid -H`
for line in $alllist; do
    CTID=$line
    if [ $CTID != 0 ]; then 
        echo $CTID
    fi
done
