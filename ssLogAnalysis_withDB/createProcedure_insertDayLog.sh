#!/bin/bash
mysql -ushadowsocks -pshadowsocks <<EOF
USE shadowsocksLogAnalysis;
DROP PROCEDURE IF EXISTS insertDayLog;

DELIMITER //
CREATE PROCEDURE insertDayLog(IN n SMALLINT, IN day_y CHAR(10),IN ip_array VARCHAR(65535), IN location_array VARCHAR(65535), IN times_array VARCHAR(65535), IN first_array VARCHAR(65535), IN last_array VARCHAR(65535))
BEGIN
DECLARE i INT DEFAULT 0; 
DECLARE day,ip,location,times,first,last VARCHAR(50); 
REPEAT 
SET i = i + 1; 
SET ip = SUBSTRING_INDEX(SUBSTRING_INDEX(ip_array, ' ', i), ' ', -1); 
SET location = SUBSTRING_INDEX(SUBSTRING_INDEX(location_array, ' ', i), ' ', -1); 
SET times = SUBSTRING_INDEX(SUBSTRING_INDEX(times_array, ' ', i), ' ', -1); 
SET first = SUBSTRING_INDEX(SUBSTRING_INDEX(first_array, ' ', i), ' ', -1); 
SET last = SUBSTRING_INDEX(SUBSTRING_INDEX(last_array, ' ', i), ' ', -1); 
INSERT INTO day VALUES(NULL,day_y,ip,location,NULL,times,first,last); 
UNTIL i >= n END REPEAT;
END
//

DELIMITER ;

EOF
