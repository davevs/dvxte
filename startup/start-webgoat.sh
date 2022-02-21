#!/bin/bash
export WEBGOAT_PORT=8200
exec java -Dfile.encoding=UTF-8 -Dserver.port=8200 -Dserver.address=0.0.0.0 -Dhsqldb.port=9001 -jar -Xms128m -Xmx128m -Xss512k -XX:MaxRAMPercentage=75 -XX:MinRAMPercentage=25 /var/www/html/webgoat/webgoat.jar