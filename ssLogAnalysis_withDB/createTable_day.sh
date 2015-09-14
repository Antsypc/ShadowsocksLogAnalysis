#!/bin/bash

mysql -u ssadmin -h localhost -pssadmin123 <<EOF
USE shadowsocks;
CREATE TABLE day(
  dayID INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  day DATE NOT NULL,
  ipUser CHAR(39) NOT NULL,
  location CHAR(50) NOT NULL,
  isNew ENUM('Y','N') DEFAULT NULL,
  dayLogTimes SMALLINT(5) UNSIGNED NOT NULL,
  firstLog DATETIME NOT NULL,
  lastLog DATETIME NOT NULL
);
EOF
