#!/bin/bash

# make sure shadowsocks.log under '/var/log'.
# if there is not shadowsocks.log, then exit.
# or you can change the location both in line 6 and line 12
if [ ! -e "/var/log/shadowsocks.log" ]
then
	echo "No such file: /var/log/shadowsocks.log"
	exit
fi

#array ips is consists of IP,latest login time,login times,
#and sorted by login times in descending order
ips=$(awk '  
	/connecting .*:[0-9]+ from .*:[0-9]+/{ 
		split($7,IP,":");
		USER[IP[1]]++;
		LatestLogin[IP[1]]=$1"/"$2;
	} 
	END{ 
		for(n in USER) 
			print n,LatestLogin[n],USER[n] | "sort -r -n -k3";
	}' /var/log/shadowsocks.log)

echo -e "IP\t\tlocation\t\t\t\tlatest login\t\tlogin times"
for ip in ${ips[@]}
do
	((i++))
	if [ $((i % 3)) == 0 ]
	then
		echo -e "\t${ip}"	#print login times
	elif [ $((i % 3)) == 1 ]
	then
		echo -ne $ip"\t"	#print IP
		# Because of the differences of awk between ubuntu and centOS,there are some different results.
		# As follow,the awk version of Debian is mawk but centOS is gawk.
		# In my test OS,the substr(a,b,c) in awk,a is the character location in ubuntu while a is the word location in centOS.
		# gawk is much more popular,while mawk maybe more efficient.
		# So,choose different command as follow.

		# mawk 1.2,print location
		curl -s "http://ip138.com/ips138.asp?ip=${ip}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' 'BEGIN{ORS=" "} {location=substr($7,19);printf("%-50s",location);}'
		# gawk 3.1.7,print location
		#curl -s "http://ip138.com/ips138.asp?ip=${ip}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' 'BEGIN{ORS=" "} {location=substr($7,7);printf("%-50s",location);}'
	elif [ $((i % 3)) == 2 ]
	then
		echo -n ${ip}	#print latest login
	fi
done

