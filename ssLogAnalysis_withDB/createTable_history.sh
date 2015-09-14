#!/bin/bash

# create history table in shadowsocksLogAnalysis to record history log analysis

mysql -u shadowsocks -pshadowsocks <<EOF

	USE shadowsocksLogAnalysis;

	CREATE TABLE IF NOT EXISTS history(
		id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
		ip CHAR(39) NOT NULL,
		location VARCHAR(50) NOT NULL,
		firstLog DATETIME NOT NULL,
		latestLog DATETIME NOT NULL,
		logTimes BIGINT UNSIGNED NOT NULL,
		logDays SMALLINT UNSIGNED NOT NULL
	);

EOF
