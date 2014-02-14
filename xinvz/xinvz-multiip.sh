#!/bin/bash
eth=$1
ip=$2
mask=$3
id=""
checketh=`ls /etc/sysconfig/network-scripts/ifcfg-$eth 2>/dev/null`
if [ -z "$checketh" ]
then
    echo "No Physical Interface $eth configuration file found! Exiting...!"
    exit 3;
else
    max=`ls /etc/sysconfig/network-scripts/ |grep $eth |awk -F: '{print $2}'|sort -n |tail -1`
    if [ "$max" == "" ]
    then
        id=0
    else
#       id=`expr $max + 1 `
        id=$[$max+1]
    fi
echo "DEVICE=$eth:$id
      ONBOOT=yes
      BOTOPROTO=no
      IPADDR=$ip
      NETMASK=$mask ">/etc/sysconfig/network-scripts/ifcfg-$eth:$id
      ifup $eth:$id
fi
echo "$?" 
