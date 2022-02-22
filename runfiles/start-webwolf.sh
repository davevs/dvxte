#!/bin/bash
# give webwolf some time to start up and not frustrate supervisor
sleep 5
exec java -Dfile.encoding=UTF-8 -Dserver.port=8300 -Dserver.address=0.0.0.0 -jar -Xms128m -Xmx128m -Xss512k -XX:MaxRAMPercentage=75 -XX:MinRAMPercentage=25 /var/www/html/webgoat/webwolf.jar