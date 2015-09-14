#!/bin/bash

mysql -ushadowsocks -pshadowsocks <<EOF

USE shadowsocksLogAnalysis;
DROP PROCEDURE IF EXISTS insertHistoryLog;

DELIMITER //
CREATE PROCEDURE insertHistoryLog(IN n SMALLINT, IN ip_array VARCHAR(65535), IN location_array VARCHAR(65535), IN first_array VARCHAR(65535), IN last_array VARCHAR(65535), IN times_array VARCHAR(65535), IN logdays_array VARCHAR(65535))
BEGIN
DECLARE i INT DEFAULT 0; 
DECLARE ip,location,times,first,last,days VARCHAR(50); 
REPEAT 
SET i = i + 1; 
SET ip = SUBSTRING_INDEX(SUBSTRING_INDEX(ip_array, ' ', i), ' ', -1); 
SET location = SUBSTRING_INDEX(SUBSTRING_INDEX(location_array, ' ', i), ' ', -1); 
SET times = SUBSTRING_INDEX(SUBSTRING_INDEX(times_array, ' ', i), ' ', -1); 
SET first = SUBSTRING_INDEX(SUBSTRING_INDEX(first_array, ' ', i), ' ', -1); 
SET last = SUBSTRING_INDEX(SUBSTRING_INDEX(last_array, ' ', i), ' ', -1); 
SET days = SUBSTRING_INDEX(SUBSTRING_INDEX(logdays_array, ' ', i), ' ', -1); 
INSERT INTO history VALUES(NULL,ip,location,first,last,times,days); 
UNTIL i >= n END REPEAT;
END
//

DELIMITER ;

EOF
