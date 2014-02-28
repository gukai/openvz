#!/bin/bash
# ebtables for isolation network communication
# need four arguments 
#like as  commad {init|addguest|delguest|del} + iface + [ip + mac]

action=$1
vmeth=$2
ip=$3
mac=$4

initebtables()
{
if [ !`brctl show |grep -i $vmeth` ]
then
    echo "$vmeth not in bridge!"
    exit
fi

local number=`ebtables -t filter -L FORWARD |grep $vmeth |wc -l`
if [ $number -gt 0 ]
then
    echo "$vmeth chains is exist"
    exit
else
    ebtables -t filter -N I-$vmeth &>/dev/null
    ebtables -t filter -N I-$vmeth-ip &>/dev/null
    ebtables -t filter -N I-$vmeth-mac &>/dev/null
    ebtables -t filter -N O-$vmeth &>/dev/null
    ebtables -t filter -N O-$vmeth-ip &>/dev/null
    ebtables -t filter -N O-$vmeth-mac &>/dev/null
    ebtables -t filter -A FORWARD -i $vmeth -j I-$vmeth
    ebtables -t filter -A FORWARD -o $vmeth -j O-$vmeth
    ebtables -t filter -A I-$vmeth -p IPv4 -j I-$vmeth-ip
    ebtables -t filter -A I-$vmeth -j I-$vmeth-mac
    ebtables -t filter -A I-$vmeth -j ACCEPT
#    ebtables -t filter -A I-$vmeth -s $mac -j ACCEPT
#    ebtables -t filter -A I-$vmeth -j DROP
    ebtables -t filter -A I-$vmeth-ip -j DROP
    ebtables -t filter -I I-$vmeth-ip 1 -p IPv4 --ip-src $ip -j RETURN
    ebtables -t filter -A I-$vmeth-mac -j DROP
    ebtables -t filter -I I-$vmeth-mac 1 -s $mac -j RETURN
    ebtables -t filter -A O-$vmeth -p IPv4 -j O-$vmeth-ip
    ebtables -t filter -A O-$vmeth -j O-$vmeth-mac
    ebtables -t filter -A O-$vmeth -p ARP -j ACCEPT
    ebtables -t filter -A O-$vmeth -j DROP
    ebtables -t filter -A O-$vmeth-ip -j DROP
    ebtables -t filter -A O-$vmeth-mac -j ACCEPT
fi
}

addguest()
{
local number=`ebtables -t filter -L O-$vmeth-mac --Lmac2 | grep -i $mac |wc -l`
if [ $number -ne 0 ]
then 
    echo "The $mac is exist"
    exit
else
    ebtables -t filter -I O-$vmeth-mac 1 -s $mac -j ACCEPT
#    local linenumber=`ebtables -t filter -L O-$vmeth --Ln |grep -i ARP |cut -d"." -f 1`
#    ebtables -t filter -I O-$vmeth-ip 1 -p IPv4 --ip-src $ip -j ACCEPT
fi

local number1=`ebtables -t filter -L O-$vmeth-ip | grep $ip |wc -l`
if [ $number1 -ne 0 ]
then
    echo "The $ip is exist"
    exit
else
    ebtables -t filter -I O-$vmeth-ip 1 -p IPv4 --ip-src $ip -j ACCEPT
fi
}

delguest()
{
local number=`ebtables -t filter -L O-$vmeth-mac --Lmac2 | grep -i $mac |wc -l`
if [ $number -eq 0 ]
then
    echo "The $mac is not exist"
    exit
else
    local line_number=`ebtables -t filter -L O-$vmeth-mac --Ln --Lmac2 | grep -i $mac |awk -F"." NR==1'{print $1}'`
    ebtables -t filter -D O-$vmeth-mac $line_number
fi

local number1=`ebtables -t filter -L O-$vmeth-ip | grep $ip |wc -l`
if [ $number1 -eq 0 ]
then
    echo "The $ip is not exist"
    exit
else
    local line_number=`ebtables -t filter -L O-$vmeth-ip --Ln | grep $ip |awk -F"." NR==1'{print $1}'`
    ebtables -t filter -D O-$vmeth-ip $line_number
fi
}

delebtables()
{
local number=`ebtables -t filter -L FORWARD |grep -i $vmeth |wc -l`
if [ $number -eq 0 ]
then
    echo "$vmeth chains is not exist"
    exit
else
    for ((i=1;i<=$number;i++))
    do
        local line_number=`ebtables -t filter -L FORWARD --Ln |grep -i $vmeth |awk -F"." NR==1'{print $1}'`
        ebtables -t filter -D FORWARD $line_number
    done
    ebtables -t filter -F I-$vmeth 
    ebtables -t filter -F O-$vmeth
    ebtables -t filter -F I-$vmeth-ip
    ebtables -t filter -F I-$vmeth-mac
    ebtables -t filter -F O-$vmeth-ip
    ebtables -t filter -F O-$vmeth-mac
    ebtables -t filter -X I-$vmeth
    ebtables -t filter -X O-$vmeth
    ebtables -t filter -X I-$vmeth-ip
    ebtables -t filter -X I-$vmeth-mac
    ebtables -t filter -X O-$vmeth-ip
    ebtables -t filter -X O-$vmeth-mac
fi
}

case "$action" in
    init|initebtables)
	initebtables
	;;
    add-guest|addguest)
	addguest
	;;
    del-guest|delguest)
	delguest
	;;
    del|delebtables)
	delebtables
	;;
    *)	
	echo $"Usage: $0 {init|addguest|delguest|del} + iface + [ip + mac]"
    
esac
echo $?
