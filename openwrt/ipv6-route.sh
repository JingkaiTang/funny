#!/usr/bin/env sh

for i in $(seq 10)
do
    v6r=$(ip -6 route show default)
    v6r_d=$(echo $v6r | awk '{ if(match($0, /default from [^ ]+ /)) printf("default %s\n", substr($0, RLENGTH+1)) }')
    if $(test -z $v6r_d); then
        sleep 30
    else
        ip -6 route del $v6r
        ip -6 route add $v6r_d
        logger -t IPv6 "Replace default route success!"
        exit 0
    fi
done
logger -t IPv6 "Replace default route failed!"
