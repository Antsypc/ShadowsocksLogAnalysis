#!/bin/bash

# make sure shadowsocks.log under this directory.
# if there is not shadowsocks.log, then exit.
if [ ! -e "shadowsocks.log" ]
then
	echo "No such file: shadowsocks.log"
	exit
fi

ips=(`awk '/connecting .*:[0-9]+ from .*:[0-9]+/{split($7,IP,":");USER[IP[1]]++;} END{for(n in USER)print n,USER[n];}' shadowsocks.log`)
i=0
for ip in ${ips[@]}
do
	i=`expr $i + 1 `
	if [ `expr $i % 2` != 0 ]
	then
		echo -ne $ip"\t"
		# ubuntu14.04 utf-8
		curl -s "http://ip138.com/ips138.asp?ip=${ip}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' 'BEGIN{ORS=" "} {location=substr($7,19);printf("%-50s",location)}'
		# centos6 utf-8
		# curl -s "http://ip138.com/ips138.asp?ip=${ip}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' 'BEGIN{ORS=" "} {location=substr($7,7);printf("%-50s",location)}'
	else
		echo -e ${ip}
	fi
done

