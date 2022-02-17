#!/bin/bash
exec java -jar /var/www/html/webgoat/webgoat.jar -httpPort=8200
exec java -jar /var/www/html/webgoat/webwolf.jar -httpPort=9090