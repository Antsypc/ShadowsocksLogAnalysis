#!/bin/bash

# get log analysis from day table in shadowsocks DB,
# and save the result into week table.

beginDay=`date --date='last Mon' +%Y-%m-%d`
endDay=`date --date='last Sun' +%Y-%m-%d`

mysql -u shadowsocks -pshadowsocks <<EOF

	USE shadowsocksLogAnalysis;

	INSERT week 
	SELECT NULL,'${beginDay}','${endDay}',ipUser,location,NULL,SUM(dayLogTimes),GROUP_CONCAT(DISTINCT day) 
	FROM day 
	WHERE TO_DAYS('${endDay}') - TO_DAYS(day.day) >= 0 AND TO_DAYS(day.day) - TO_DAYS('${beginDay}') >= 0 
	GROUP BY ipUser 
	ORDER BY isNew,SUM(dayLogTimes) DESC;

EOF
