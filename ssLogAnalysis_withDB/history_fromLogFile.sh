#!/bin/bash

# this shell script :
# get history log analysis from 'shadowsocks.log' and save the message into mysql.

# make sure shadowsocks.log under '/var/log'.
# if there is not shadowsocks.log, then exit.
# or you can change the location both in line 9 and line 11
if [ ! -e "/var/log/shadowsocks.log" ]
then
	echo "No such file: /var/log/shadowsocks.log"
	exit
fi

# get ip_array,location_array,times_array,first_log_array,last_log_array
#array dayLogInfo is consists of IP,first login and last login of this IP yesterday,login times of this IP yesterday
dayLogInfo=$(awk '  
	/connecting .*:[0-9]+ from .*:[0-9]+/{ 
		split($7,IP,":");
		LogTimes[IP[1]]++;
		if(FirstLogin[IP[1]] == "")
			FirstLogin[IP[1]]=$1"/"$2;
		LastLogin[IP[1]]=$1"/"$2;
		if(index(LogDays[IP[1]],$1) == 0)
			LogDays[IP[1]]=LogDays[IP[1]]$1;
	} 
	END{ 
		for(ip in LogTimes) 
			print ip,FirstLogin[ip],LastLogin[ip],LogTimes[ip],length(LogDays[ip])/10;
	}' /var/log/shadowsocks.log)

i=0
for e in ${dayLogInfo[@]}
do
	if [ $((i % 5)) == 0 ]
	then
		ip_array[i/5]=$e
		# mawk 1.2,print location
		location_array[i/5]=$(curl -s "http://ip138.com/ips138.asp?ip=${e}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' '{loc=substr($7,19);gsub(/ +/,",",loc);gsub(/[\b\t\n,]+$/,"",loc);print loc;}')
		# gawk 3.1.7,print location
		#location_array[i]=$(curl -s "http://ip138.com/ips138.asp?ip=${e}&action=2" | iconv -f gb2312 -t utf-8 | grep '<ul class="ul1"><li>' | awk -F'[><]' '{loc=substr($7,7);gsub(/ +/,",",loc);print loc;}')
	elif [ $((i % 5)) == 1 ]
	then
		firstlog_array[i/5]=$e
	elif [ $((i % 5)) == 2 ]
	then
		lastlog_array[i/5]=$e
	elif [ $((i % 5)) == 3 ]
	then
		logtimes_array[i/5]=$e
	elif [ $((i % 5)) == 4 ]
	then
		logdays_array[i/5]=$e
	fi
	((i++))
done

((i=i/5))
echo -e $i"\n\n"
echo -e "iparray\n"${ip_array[*]}
echo -e "locationarray\n"${location_array[*]}
echo -e "firstarray\n"${firstlog_array[*]}
echo -e "lastarray\n"${lastlog_array[*]}
echo -e "timesarray\n"${logtimes_array[*]}
echo -e "daysarray\n"${logdays_array[*]}

# multi annotation for database operations
:<< EOF

# create procedure insertDayLog in MySQL
	mysql> DEMILITER //
	mysql> CREATE PROCEDURE insertDayLog(
			IN n SMALLINT, 
			IN day_y CHAR(10),
			IN ip_array VARCHAR(65535), 
			IN location_array VARCHAR(65535), 
			IN times_array VARCHAR(65535), 
			IN first_array VARCHAR(65535), 
			IN last_array VARCHAR(65535))
		BEGIN 
			DECLARE i INT DEFAULT 0; 
			DECLARE day,ip,location,times,first,last VARCHAR(50); 
			REPEAT 
				SET i        = i + 1; 
				SET ip       = SUBSTRING_INDEX(SUBSTRING_INDEX(ip_array, ' ', i), ' ', -1); 
				SET location = SUBSTRING_INDEX(SUBSTRING_INDEX(location_array, ' ', i), ' ', -1); 
				SET times    = SUBSTRING_INDEX(SUBSTRING_INDEX(times_array, ' ', i), ' ', -1); 
				SET first    = SUBSTRING_INDEX(SUBSTRING_INDEX(first_array, ' ', i), ' ', -1); 
				SET last     = SUBSTRING_INDEX(SUBSTRING_INDEX(last_array, ' ', i), ' ', -1); 
				INSERT INTO day VALUES(NULL,day_y,ip,location,NULL,times,first,last); 
			UNTIL i >= n END REPEAT;
		END
		//
	mysql> DELIMITER ;
EOF

mysql -ushadowsocks -pshadowsocks << EOF
	USE shadowsocksLogAnalysis;
	CALL insertHistoryLog($i,'${ip_array[*]}','${location_array[*]}','${firstlog_array[*]}','${lastlog_array[*]}','${logtimes_array[*]}','${logdays_array[*]}');
	
EOF

