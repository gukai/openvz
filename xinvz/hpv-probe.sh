#!/bin/sh
rpm -q vzkernel >/dev/null 2>&1
ret=$?
if [ $ret -eq 0 ] ; then
    echo "OpenVZ"
else
    echo "KVM"
fi
