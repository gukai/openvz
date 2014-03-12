#!/bin/sh
var=$1

echo "$var" | gawk '{
    if ($0 ~ /^[0-9]+$/){
        print "Number "
    } else if ($0 ~ /^[A-Za-z]+$/){
        print "String "
        #print ${var:n1}
    } else {
        print "Mixed number and string or others"
    }
}'


