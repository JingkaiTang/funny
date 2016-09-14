#!/usr/bin/env bash
date "+%Y-%m-%d %H:%M:%S"
question=http://www.qlcoder.com/train/autocr
cookie=`cat cookiefile`
page=`curl -b "$cookie"  "$question" 2> /dev/null`
level=`echo $page | grep -Po 'level=([0-9]+)&x=([0-9]+)&y=([0-9]+)&map=([0-1]+)'`
echo $level
condition=`echo "$level" | awk -F '=|&' '{print($4 " " $6 " " $8)}'`
answer=`./autocr.rb $condition`
echo $answer
qcode=`echo "$answer" | awk '{print("x=" $1 "&y=" $2 "&path=" $3)}'`
submit=http://www.qlcoder.com/train/crcheck?$qcode
curl -b "$cookie" "$submit"


