#!/bin/sh
    #delete inactive snapshot first.
    dellist=`./xmltree build /vz/private/301/root.hdd/DiskDescriptor.xml`
    echo $dellist
    for snaptmp in $dellist; do
        echo $snaptmp
        snapuuid=`echo $snaptmp | cut -d '{' -f 2 | cut -d '}' -f 1`
        echo "I will delete $snapuuid"
        #ploop snapshot-delete -u $snapuuid ${private_path}/root.hdd/DiskDescriptor.xml
    done
