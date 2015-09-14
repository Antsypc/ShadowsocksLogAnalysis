#!/bin/bash

mysql -u shadowsocks -pshadowsocks <<EOF

	USE shadowsocksLogAnalysis;
	CREATE TABLE IF NOT EXISTS week(
		weekID INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
		beginDay DATE NOT NULL,
		endDay DATE NOT NULL,
		ip CHAR(39) NOT NULL,
		location CHAR(50) NOT NULL,
		isNew ENUM('Y','N') DEFAULT NULL,
		weekLogTimes MEDIUMINT UNSIGNED NOT NULL,
		logDays CHAR(13) NOT NULL
	);

EOF
