#!/bin/bash
export WEBWOLF_PORT=8300
exec java -Dfile.encoding=UTF-8 -Dserver.port=8300 -Dserver.address=0.0.0.0 -jar /var/www/html/webgoat/webwolf.jar