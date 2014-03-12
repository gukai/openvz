#!/bin/sh
CTID=110

#PAG=`getconf PAGESIZE`
#PAGKB=`expr $PAGESIZE / 1024`

getvmpages(){
    CONFIGFILE=/etc/vz/conf/${CTID}.conf
    . $CONFIGFILE

    vmpages=$(printf %s "$PHYSPAGES" | tr ':' '\n')
    pages=`echo $vmpages | awk {'print $2;'}`
    echo $pages
}

alllist=`vzlist --all -o ctid -H`
for line in $alllist; do
    CTID=$line
    if [ $CTID != 0 ]; then
        pages=`getvmpages`
        echo $CTID "pages unchuli is " $pages   

        if [[ $pages =~ ^[0-9]+$ ]];then
            echo "Number."
            pages=`expr $pages \* 4`
            #num=`expr $pages * 4`
        elif [[ $pages =~ ^[A-Za-z]+$ ]];then
            echo "String."
            pages=0
            echo $CTID " vmpages in kb is unlimit, zero we set"
        else
            echo "mixed number and string or others "
            long=`echo $pages | wc -m`
            posunit=`expr $long - 2`
            #posnum=`expr $long - 3`
            echo "long " $long
            unit=`eval echo ${pages:$posunit}`
            num=`eval echo ${pages:0:$posunit}`
            #why the 'm' is not work here.
            if [ $unit == 'M' ] || [ $unit == 'm' ]; then
               #echo "it is M"
               #echo "num is " $num
               pages=`expr $num \* 1024`
            elif [ $unit == 'G' ] || [ $unit == 'g' ]; then
               #echo "it is G " $num
               pages=`expr $num \* 1024 * 1024`
            fi
        fi

        totalpages=`expr $totalpages + $pages`
        echo "totall pages now is " $totalpages
        echo "**************************************"
    fi
done

echo $totalpages


