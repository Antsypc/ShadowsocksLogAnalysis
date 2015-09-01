#!/bin/bash

# make sure shadowsocks.log under '/var/log'.
# if there is not shadowsocks.log, then exit.
# or you can change the location both in line 6 and line 12
if [ ! -e "/var/log/shadowsocks.log" ]
then
	echo "No such file: /var/log/shadowsocks.log"
	exit
fi

ips=(`awk '/connecting .*:[0-9]+ from .*:[0-9]+/{split($7,IP,":");USER[IP[1]]++;} END{for(n in USER)print n,USER[n];}' /var/log/shadowsocks.log`)
echo -e "IP\t\tlocation\t\t\t\tlogin times"
for ip in ${ips[@]}
do
	((i++))
	if [ $((i % 2)) != 0 ]
	then
		echo -ne $ip"\t"
		# Because of the differences of awk between ubuntu and centOS,there are some different results.
		# As follow,the awk version of Debian is mawk but centOS is gawk.
		# In my test OS,the substr(a,b,c) in awk,a is the character location in ubuntu while a is the word location in centOS.
		# gawk is much more popular,while mawk maybe more efficient.
		# So,choose different command as follow.

		# mawk 1.2
		curl -s "http://ip138.com/ips138.asp?ip=${ip}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' 'BEGIN{ORS=" "} {location=substr($7,19);printf("%-50s",location)}'
		# gawk 3.1.7
		#curl -s "http://ip138.com/ips138.asp?ip=${ip}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' 'BEGIN{ORS=" "} {location=substr($7,7);printf("%-50s",location);}'
	else
		echo -e ${ip}
	fi
done

