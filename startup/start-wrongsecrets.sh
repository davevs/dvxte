#!/bin/bash
export WRONGSECRETS_PORT=8300
exec java -Xms128m -Xmx128m -Xss512k -jar -Dserver.port=8400 -XX:MaxRAMPercentage=75 -XX:MinRAMPercentage=25 -Dspring.profiles.active=$(echo ${SPRING_PROFILES_ACTIVE}) /var/www/html/wrongsecrets/wrongsecrets.jar

