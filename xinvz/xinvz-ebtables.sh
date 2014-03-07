#!/bin/bash
# ebtables in nat chain
# ebtables for isolation network communication
# need five arguments 
# like as  commad {init|addguest|delguest|del} + iface + [ip + mac] + protocol + port
# if action is init {init + iface + ip + mac}
# if action is addguest {addguest + iface + ip + [protocol + dport]}
# if action is delguest {delguest + iface + ip + [protocol + dport]}
# if action is del  {del + iface}
# if want allow all traffic,use ip={0.0.0.0|0.0.0.0/0|0} 
# use init + iface +ip + mac  to initialize interface,default deny all traffic  eg: ./ebtables init eth0 10.0.0.1 00:00:00:00:00:01
# usually use addguest + iface + ip to allow special ip traffic                 eg: /ebtables addguest eth0 10.0.0.2
# delete interface all rule                                                     eg: ./ebtables del eth0 
# othen use:
# allow all traffic                                                             eg: ./ebtables addguest eth0 0
# allow all tcp traffic                                                         eg: ./ebtables addguest eth0 0 tcp
# allow all tcp to destination ssh                                              eg: ./ebtables addguest eth0 0 tcp 22
# allow spetial ip tcp traffic                                                  eg: ./ebtables addguest eth0 10.0.0.2 tcp
# delete spectial traffic                                                       eg: ./ebtables delguest eth0 10.0.0.2 tcp


action=$1
vmeth=$2

initebtables ()
{
if [ "`brctl show |grep -i $vmeth`" = "" ]
then
    echo "$vmeth not in bridge!"
    exit
fi
    ebtables -t nat -N I-$vmeth          &>/dev/null
    ebtables -t nat -N O-$vmeth          &>/dev/null
    ebtables -t nat -N I-$vmeth-mac      &>/dev/null
    ebtables -t nat -N I-$vmeth-ipv4     &>/dev/null
    ebtables -t nat -N I-$vmeth-arp-mac  &>/dev/null
    ebtables -t nat -N I-$vmeth-arp-ip   &>/dev/null
    ebtables -t nat -N I-$vmeth-rarp     &>/dev/null
    ebtables -t nat -N O-$vmeth-ipv4     &>/dev/null
    ebtables -t nat -N O-$vmeth-rarp     &>/dev/null
    #add a new rule in nat table PREROUTING chain
if [ "`ebtables -t nat -L PREROUTING | grep -i $vmeth`" = "" ]
then
    ebtables -t nat -A PREROUTING -i $vmeth -j I-$vmeth
fi

if [ "`ebtables -t nat -L POSTROUTING | grep -i $vmeth`" = "" ]
then
    #add a new rule in nat table POSTROUTING chain
    ebtables -t nat -A POSTROUTING -o $vmeth -j O-$vmeth
fi
    #add new rules in nat table $vmeth chain
    ebtables -t nat -A I-$vmeth -j I-$vmeth-mac
    ebtables -t nat -A I-$vmeth -p IPv4 -j I-$vmeth-ipv4
    ebtables -t nat -A I-$vmeth -p IPv4 -j ACCEPT
    ebtables -t nat -A I-$vmeth -p ARP -j I-$vmeth-arp-mac
    ebtables -t nat -A I-$vmeth -p ARP -j I-$vmeth-arp-ip
    ebtables -t nat -A I-$vmeth -p 0x8035 -j I-$vmeth-rarp
    ebtables -t nat -A I-$vmeth -p ARP -j ACCEPT
    ebtables -t nat -A I-$vmeth -p 0x8035 -j ACCEPT
    ebtables -t nat -A I-$vmeth -j DROP
    ebtables -t nat -A O-$vmeth -p IPv4 -j O-$vmeth-ipv4
    ebtables -t nat -A O-$vmeth -p 0x8035 -j O-$vmeth-rarp
    ebtables -t nat -A O-$vmeth -p ARP -j ACCEPT
    ebtables -t nat -A O-$vmeth -j DROP
    #I-$vmeth-mac
    ebtables -t nat -A I-$vmeth-mac -s $mac -j RETURN
    ebtables -t nat -A I-$vmeth-mac -j DROP
    #I-$vmeth-ip-ipv4
    ebtables -t nat -A I-$vmeth-ipv4 -p IPv4 --ip-src 0.0.0.0 --ip-proto udp -j RETURN
    ebtables -t nat -A I-$vmeth-ipv4 -p IPv4 --ip-src $ip -j RETURN
    ebtables -t nat -A I-$vmeth-ipv4 -j DROP
    #I-$vmeth-arp-mac
    ebtables -t nat -A I-$vmeth-arp-mac -p ARP --arp-mac-src $mac -j RETURN
    ebtables -t nat -A I-$vmeth-arp-mac -j DROP
    #I-$vmeth-arp-ip
    ebtables -t nat -A I-$vmeth-arp-ip -p ARP --arp-ip-src $ip -j RETURN
    ebtables -t nat -A I-$vmeth-arp-ip -j DROP
    #I-$vmeth-rarp
    ebtables -t nat -A I-$vmeth-rarp -p 0x8035 -s $mac -d Broadcast --arp-op Request_Reverse \
        --arp-ip-src 0.0.0.0 --arp-ip-dst 0.0.0.0 --arp-mac-src $mac --arp-mac-dst $mac -j ACCEPT
    ebtables -t nat -A I-$vmeth-rarp -j DROP
    #O-$vmeth-ipv4
    ebtables -t nat -A O-$vmeth-ipv4 -j DROP
   #ebtables -t nat -A O-$vmeth-ipv4 -j ACCEPT
    #O-$vmeth-rarp
    ebtables -t nat -A O-$vmeth-rarp -p 0x8035 -d Broadcast --arp-op Request_Reverse --arp-ip-src 0.0.0.0 \
        --arp-ip-dst 0.0.0.0 --arp-mac-src $mac --arp-mac-dst $mac -j ACCEPT
    ebtables -t nat -A O-$vmeth-rarp -j DROP
}

delebtables ()
{
if [ "`brctl show |grep -i $vmeth`" = "" ]
then
    echo "$vmeth not in bridge!"
    exit
fi
    ebtables -t nat -F I-$vmeth  &>/dev/null
    ebtables -t nat -F O-$vmeth  &>/dev/null
    ebtables -t nat -F I-$vmeth-mac  &>/dev/null
    ebtables -t nat -F I-$vmeth-ipv4  &>/dev/null
    ebtables -t nat -F I-$vmeth-arp-mac  &>/dev/null
    ebtables -t nat -F I-$vmeth-arp-ip  &>/dev/null
    ebtables -t nat -F I-$vmeth-rarp  &>/dev/null
    ebtables -t nat -F O-$vmeth-ipv4  &>/dev/null
    ebtables -t nat -F O-$vmeth-rarp  &>/dev/null
    ebtables -t nat -L PREROUTING --Ln | grep $vmeth |cut -d"." -f 1 | sort -r |  xargs -i ebtables -t nat -D PREROUTING {}  &>/dev/null
    ebtables -t nat -L POSTROUTING --Ln | grep $vmeth |cut -d"." -f 1 | sort -r | xargs -i ebtables -t nat -D POSTROUTING {}  &>/dev/null
    ebtables -t nat -X I-$vmeth  &>/dev/null
    ebtables -t nat -X O-$vmeth  &>/dev/null
    ebtables -t nat -X I-$vmeth-mac  &>/dev/null
    ebtables -t nat -X I-$vmeth-ipv4  &>/dev/null
    ebtables -t nat -X I-$vmeth-arp-mac  &>/dev/null
    ebtables -t nat -X I-$vmeth-arp-ip  &>/dev/null
    ebtables -t nat -X I-$vmeth-rarp  &>/dev/null
    ebtables -t nat -X O-$vmeth-ipv4  &>/dev/null
    ebtables -t nat -X O-$vmeth-rarp  &>/dev/null
}

addguest()
{
if [ "`brctl show |grep -i $vmeth`" = "" ]
then
    echo "$vmeth not in bridge!"
    exit
fi

if [ $# = 1 ]
then
    if [ "$ip" = "0.0.0.0" -o "$ip" = "0.0.0.0/0" -o "$ip" = "0" ]
    then
        ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 -j ACCEPT
    else
        ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-src $ip -j ACCEPT
    fi
fi

if [ $# = 2 ]
then
    if [ "$ip" = "0.0.0.0" -o "$ip" = "0.0.0.0/0" -o "$ip" = "0" ]
    then
        ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-proto $protocol -j ACCEPT
    else
        ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-src $ip --ip-proto $protocol -j ACCEPT
    fi
fi

if [ $# = 3 ]
then
    if [ "$ip" = "0.0.0.0" -o "$ip" = "0.0.0.0/0" -o "$ip" = "0" ]
    then
        if [ "$protocol" = "icmp" ]
        then
            ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-proto $protocol -j ACCEPT
        else
            ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-proto $protocol --ip-dport $dport -j ACCEPT
        fi
    else
        if [ "$protocol" = "tcp" -o "$protocol" = "udp" ]
        then
            ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-src $ip --ip-proto $protocol --ip-dport $dport -j ACCEPT 
        else
            ebtables -t nat -I O-$vmeth-ipv4 1 -p IPv4 --ip-src $ip --ip-proto $protocol -j ACCEPT
        fi
    fi
fi
}

delguest()
{
if [ "`brctl show |grep -i $vmeth`" = "" ]
then
    echo "$vmeth not in bridge!"
    exit
fi

if [ $# = 1 ]
then
    if [ "$ip" = "0.0.0.0" -o "$ip" = "0.0.0.0/0" -o "$ip" = "0" ]
    then
        ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4-jaccept" | cut -d"." -f 1 | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
    else
        ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-src$ip-jaccept" | cut -d"." -f 1 | sort -r \
        | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
    fi
fi

if [ $# = 2 ]
then
    if [ "$ip" = "0.0.0.0" -o "$ip" = "0.0.0.0/0" -o "$ip" = "0" ]
    then
        ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-proto$protocol-jaccept" | cut -d"." -f 1 \
        | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
    else
        ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-src$ip--ip-proto$protocol-jaccept" | cut -d"." -f 1 \
        | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
    fi
fi

if [ $# = 3 ]
then
    if [ "$ip" = "0.0.0.0" -o "$ip" = "0.0.0.0/0" -o "$ip" = "0" ]
    then
        if [ "$protocol" = "icmp" ]
        then
            ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-proto$protocol-jaccept" | cut -d"." -f 1 \
            | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
        else
            ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-proto$protocol--ip-dport$dport-jaccept" | cut -d"." -f 1 \
            | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
        fi
    else
        if [ "$protocol" = "tcp" -o "$protocol" = "udp" ]
        then
            ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-src$ip--ip-proto$protocol--ip-dport$dport-jaccept" | cut -d"." -f 1 \
            | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
        else
            ebtables -t nat -L O-$vmeth-ipv4 --Ln | tr -d " " | grep -i "pipv4--ip-src$ip--ip-proto$protocol-jaccept" | cut -d"." -f 1 \
            | sort -r | xargs -i ebtables -t nat -D O-$vmeth-ipv4 {}
	fi
    fi
fi
}

case "$action" in
    init|initebtables)
        ip=$3
        mac=$4
        initebtables $ip $mac 
        ;;
    add-guest|addguest)
        ip=$3
        protocol=$4
        dport=$5
        if [ "$protocol" != "" -a "$dport" != "" ]
        then
            addguest $ip $protocol $dport
        elif [ "$protocol" != "" ]
        then
            addguest $ip $protocol
        else
            addguest $ip
        fi
        ;;
    del-guest|delguest)
        ip=$3
        protocol=$4
        dport=$5
        if [ "$protocol" != "" -a "$dport" != "" ]
        then
            delguest $ip $protocol $dport
        elif [ "$protocol" != "" ]
        then
            delguest $ip $protocol
        else
            delguest $ip
        fi
        ;;
    del|delebtables)
        delebtables
        ;;
    *)	
        echo $"Usage: $0 {init|addguest|delguest|del} + iface + [ip|mac] + protocol + port"
esac

if [ "`chkconfig |grep ebtables | awk '{print $4$5$7}'`" != "2:on3:on5:on" ]
then
    chkconfig ebtables --levels 235 on
fi

service ebtables save
echo $?
