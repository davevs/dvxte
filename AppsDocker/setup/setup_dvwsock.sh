#!/bin/bash
sed -i 's/root/admin/g' /app/dvwsock/includes/connect-db.php
echo "sed -i \"s/toor/\$PASS/g\" /app/dvwsock/includes/connect-db.php" >> /mysql-setup.sh
echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /mysql-setup.sh
