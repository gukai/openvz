#!/bin/sh
CTID=109
cpu_record(){
    local log_record=$(vzctl exec $CTID cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')
    local id_record=$(vzctl exec $CTID echo $log_record | awk '{print $4}')
    total_record=$(echo $log_record | awk '{print $1+$2+$3+$4+$5+$6+$7}')
    echo ${total_record},${id_record}
}

date1=`cpu_record`
date2=`cpu_record`

total1=`echo $date1 | awk -F "," '{print $1}'`
total2=`echo $date2 | awk -F "," '{print $1}'`
id1=`echo $date1 | awk -F "," '{print $2}'`
id2=`echo $date2 | awk -F "," '{print $2}'`

total=`expr $total2 - $total1`
id=`expr $id2 - $id1`
used=`expr $total -$id`

#example
#awk 'BEGIN{printf "%.2f%\n",'$num1'/'$num2'}'
awk 'BEGIN{printf "%.2f\n", ('$used'/'$total')*100}'
#eval awk 'BEGIN{printf"%.2f",$used/$total}'
#rate=`expr $id / $total`
#echo $rate
