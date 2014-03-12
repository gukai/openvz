#!/bin/sh

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
alllist=`vzlist --all -o ctid -H`
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

memret=`getall getmem`
diskret=`getall getdisk`
echo $memret 
echo $diskret
