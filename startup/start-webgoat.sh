#!/bin/bash
exec java -jar /var/www/html/webgoat/webgoat-server-8.2.2.jar -httpPort=8200
exec java -jar /var/www/html/webgoat/webwolf-8.2.2.jar -httpPort=9090