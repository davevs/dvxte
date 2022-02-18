#!/bin/bash
export WEBGOAT_PORT=8200
exec java -Dfile.encoding=UTF-8 -Dserver.port=8200 -Dserver.address=0.0.0.0 -Dhsqldb.port=9001 -jar /var/www/html/webgoat/webgoat.jar
sleep 5
exec java -Dfile.encoding=UTF-8 -Dserver.port=9090 -Dserver.address=0.0.0.0 -jar /var/www/html/webgoat/webwolf.jar
