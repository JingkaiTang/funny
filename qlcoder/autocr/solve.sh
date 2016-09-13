#!/usr/bin/env bash
question=http://www.qlcoder.com/train/autocr
cookie=`cat cookiefile`
level=`curl -b "$cookie"  "$question" | grep -Po 'level=([0-9]+)&x=([1-9]+)&y=([0-9]+)&map=([0-1]+)'`
echo $level
condition=`echo "$level" | awk -F '=|&' '{print($4 " " $6 " " $8)}'`
answer=`./autocr.rb $condition`
echo $answer
qcode=`echo "$answer" | awk '{print("x=" $1 "&y=" $2 "&path=" $3)}'`
echo $qcode
submit=http://www.qlcoder.com/train/crcheck?$qcode
curl -b "$cookie" "$submit"

