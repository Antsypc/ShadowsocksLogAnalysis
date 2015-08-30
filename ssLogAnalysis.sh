#!/bin/bash

# make sure shadowsocks.log under this directory.
# if there is not shadowsocks.log, then exit.
if [ ! -e "shadowsocks.log" ]
then
	echo "No such file: shadowsocks.log"
	exit
fi

awk '/connecting .*:[0-9]+ from .*:[0-9]+/{split($7,IP,":");USER[IP[1]]++;} END{print "user","        login times"; for(n in USER)print n,USER[n];}' shadowsocks.log

exit
