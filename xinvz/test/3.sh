#!/bin/sh
var=$1

if [[ $var =~ ^[0-9]+$ ]];then
    echo "Number."
elif [[ $var =~ ^[A-Za-z]+$ ]];then
    echo "String."
else
    echo "mixed number and string or others "
    #echo ${var:n1}
    long=`echo $var | wc -m`
    posunit=`expr $long - 2`
    #posnum=`expr $long - 3`
    echo "long " $long
    unit=`eval echo ${var:$posunit}`
    num=`eval echo ${var:0:$posunit}`
    if [ $unit == 'M' ] || [ $unit == 'm' ]; then
        echo "it is M"
        echo "num is " $num 
    elif [ $unit == 'G' ]; then
        echo "it is G " $num
    fi
fi  
