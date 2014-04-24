#!/bin/sh
activelist=`./1 delete /vz/private/301/root.hdd/DiskDescriptor.xml {c20d7cc2-80db-4787-b8b3-8b35512a65f4} active | sed -n '2 p'`
realv=${activelist%{*}
echo $realv
