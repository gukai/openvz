#!/bin/sh
CTID=109
cpu_record(){
    local log_record=$(vzctl exec $CTID cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
    local id_record=$(vzctl exec $CTID echo $log_record | awk '{print $4}')
    local total_record=$(echo $log_record | awk '{print $1+$2+$3+$4+$5+$6+$7}')
    local used_record=`expr $total_record - $id_record`
    echo ${total_record},${used_record}
}

cpu_rate(){
    date1=`cpu_record`
    #precision is low, but decrease the time when handle too much machine.
    #think about muti-process.
    usleep 100000
    date2=`cpu_record`

    total1=`echo $date1 | awk -F "," '{print $1}'`
    total2=`echo $date2 | awk -F "," '{print $1}'`
    used1=`echo $date1 | awk -F "," '{print $2}'`
    used2=`echo $date2 | awk -F "," '{print $2}'`

    total=`expr $total2 - $total1`
    used=`expr $used2 - $used1`

    #example
    #awk 'BEGIN{printf "%.2f%\n",'$num1'/'$num2'}'
    awk 'BEGIN{printf "%.0f\n", ('$used'/'$total')*100}'
    echo $total
    #echo $used
}
cpu_rate


#ret=`cpu_rate`
#echo "func 1:" $ret



#cpu_rate2(){
#    local id=`vzctl exec 109 top -bn 1 | grep 'Cpu(s)' | awk -F "," '{print $4}'| cut -d'%' -f1 | cut -d' ' -f2`
#    echo $id
#    #awk 'BEGIN{printf "%.0f\n", 100-'$id'}'
#
#
#}
#cpu_rate2
