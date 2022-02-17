#!/bin/bash
cd /var/www/html/dvwsock
exec php ws-socket.php --heartbeat-interval 10
