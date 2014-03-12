#!/bin/sh

#count cpu_used_rate,memory_used_rate,disk_used_rate 
#@liuhaibin 2014-1-10
if [ $# != 1 ]
then
        echo "ERROR: The number of parameters is error !"
        exit 1
fi
if [ ! -x "$1" ];then
        echo "ERROR: The path is not exist !"
        exit 1
fi

#disk_used_rate
#Depend on real storage place the parameter 'Location' need to alter.

Location=$1
num=`df -h $Location |wc -l`
if [ $num == 2 ];then
Disk_Used_Rate=`df -h $Location | awk 'NR==2{print $5}'| cut -d'%' -f1`
disk_total=`df -h $Location | awk 'NR==2{print $2}'|cut -d'G' -f1 |cut -d'M' -f1|cut -d'K' -f1`
else
Disk_Used_Rate=`df -h $Location | awk 'NR==3{print $4}'|cut -d'%' -f1`
disk_total=`df -h $Location | awk 'NR==3{print $1}'|cut -d'G' -f1 |cut -d'M' -f1|cut -d'K' -f1`
fi

#echo $Disk_Used_Rate

#memory_used_rate
LoadMemory=$(cat /proc/meminfo | awk '{print $2}')
Total=$(echo $LoadMemory | awk '{print $1}')
Free1=$(echo $LoadMemory | awk '{print $2}')
Free2=$(echo $LoadMemory | awk '{print $3}')
Free3=$(echo $LoadMemory | awk '{print $4}')

Used=`expr $Total - $Free1 - $Free2 - $Free3`
Used_Rate=`echo  $Used/$Total*100 | bc -l`
Memory_Used_Rate=`echo  $Used_Rate/1 | bc`
#echo $Memory_Used_Rate%
mem_total=`expr $Total / 1024`
#cpu_used_rate
Log1=$(cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
Sys1=$(echo $Log1 | awk '{print $4}')
Total1=$(echo $Log1 | awk '{print $1+$2+$3+$4+$5+$6+$7}')
sleep 1
Log2=$(cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
Sys2=$(echo $Log2 | awk '{print $4}')
Total2=$(echo $Log2 | awk '{print $1+$2+$3+$4+$5+$6+$7}')
Sys=`expr $Sys2 - $Sys1`
Total_cpu=`expr $Total2 - $Total1`

usage=`echo $Sys/$Total_cpu*100|bc -l`
cpu_usage=`echo $usage/1|bc`
#cpu_number
cpu_num=`cat /proc/cpuinfo |grep processor|wc -l`
#hostname
host_name="`hostname`"

################################################################
#declare -i num1=`virsh list --all|awk '{print $2}'|wc -l`
#sum=0
#for ((i=3;i<$num1;i++));do
#        vm=`virsh list --all|sed -n "$i,1p"|awk '{print $2}'`
#	declare -i vm_mem=`virsh dominfo $vm|awk NR==8'{print $3}'
#	let sum+=vm_mem
#done
#Allocated_mem=`expr $sum / 1024`
#declare -i num2=`virsh pool-list|grep local|wc -l`
#sum2=0
#for ((i=1;i<=$num2;i++));do
#	pool=`virsh pool-list|grep local|sed -n "$i,1p"|awk '{print $1}'`
#	declare -i num3=`virsh vol-list $pool|wc -l`
#	for ((j=3;j<$num3;j++));do
#		vol=`virsh vol-list $pool|sed -n "$j,1p"|awk '{print $2}'`
#		vm_disk=`virsh vol-info $vol |awk NR==3'{print $2}'`
#		sum2=`echo $sum2+$vm_disk|bc`
#	done
#done
#Allocated_disk=$sum2
###################################################################
#PAG=`getconf PAGESIZE`
#PAGKB=`expr $PAGESIZE / 1024`

getmem(){
    CONFIGFILE=/etc/vz/conf/${CTID}.conf
    . $CONFIGFILE

    vmpages=$(printf %s "$PHYSPAGES" | tr ':' '\n')
    pages=`echo $vmpages | awk {'print $2;'}`
    echo $pages
}

getdisk(){
    CONFIGFILE=/etc/vz/conf/${CTID}.conf
    . $CONFIGFILE

    vmpages=$(printf %s "$DISKSPACE" | tr ':' '\n')
    pages=`echo $vmpages | awk {'print $1;'}`
    echo $pages
}

getall(){
vzcmd=$1
#alllist=`vzlist --all -o ctid -H`
alllist=""
for line in $alllist; do
    CTID=$line
    if [ $CTID != 0 ]; then
        eval pages=`$vzcmd`
        #echo $CTID "pages unchuli is " $pages

        if [[ $pages =~ ^[0-9]+$ ]];then
            #echo "Number."
            pages=`expr $pages \* 4`
        elif [[ $pages =~ ^[A-Za-z]+$ ]];then
            #echo "String."
            pages=0
            #echo $CTID " vmpages in kb is unlimit, zero we set"
        else
            #echo "mixed number and string or others "
            long=`echo $pages | wc -m`
            posunit=`expr $long - 2`
            #posnum=`expr $long - 3`
            #echo "long " $long
            unit=`eval echo ${pages:$posunit}`
            num=`eval echo ${pages:0:$posunit}`
            #why the 'm' is not work here.
            if [ $unit == 'M' ] || [ $unit == 'm' ]; then
               #echo "it is M"
               #echo "num is " $num
               pages=`expr $num \* 1024`
            elif [ $unit == 'G' ] || [ $unit == 'g' ]; then
               #echo "it is G " $num
               pages=`expr $num \* 1024 \* 1024`
            fi
        fi

        totalpages=`expr $totalpages + $pages`
        #echo "totall pages now is " $totalpages
        #echo "**************************************"
    fi
done

echo $totalpages
}

Allocated_mem=`getall getmem`
Allocated_disk=`getall getdisk`
if [ ! -n "$Allocated_mem" ]; then
   Allocated_mem=0
fi
if [ ! -n "$Allocated_disk" ]; then
   Allocated_disk=0
fi
#echo $memret
#echo $diskret


echo $host_name "OpenVZ "$cpu_num $cpu_usage $mem_total $Memory_Used_Rate $disk_total $Disk_Used_Rate $Allocated_mem $Allocated_disk
#Log2=$(cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
#Sys2=$(echo $Log2 | awk '{print $4}')
#Total2=$(echo $Log2 | awk '{print $1+$2+$3+$4+$5+$6+$7}')

#Sys=`expr $Sys2 - $Sys1`


