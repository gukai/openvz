#!/bin/sh
# Author: gukai(gukai@xinnet.com)
# aotu create template, iso type will create template in by iso(can't put yourself pcgk in); path is the normally func.

# FIX ME
# Used to create clean VM Template
# Not finished.


create-path(}{
    if [ ! -d $SRCPATH ]; then
        cd $SRCPATH
        createrepo .

        
####MAIN#####
TEMP=`getopt -o t:s:d: --long type:,srctype:,destpath: \
     -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "ERROR" >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
        case "$1" in
                -t| --type) TYPE=$2 ; shift 2 ;;
                -c|--srcpath) SRCPATH=$2; shift 2 ;;
                -b|--destpath) DESTPATH=$2 ; shift 2 ;;
                --) shift ; break ;;
                *) echo "Unknow Option, verfiy your command" ; usage-usage; exit 1 ;;
        esac
done

if [ -z ${TYPE} ];then
    echo "ERROR"
    echo "command cant be null"
    exit 1
fi

case $TYPE in
    path) create-path ;;
    *) usage;;
esac
exit $?
