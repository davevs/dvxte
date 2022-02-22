#!/bin/bash

# install fresh MySQL and create random admin password
rm -rf /var/lib/mysql/*
echo "=> Installing MySQL ..."
mysql_install_db > /dev/null 2>&1
/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Deleting anonymous user"
mysql -uroot -e "DROP user ''@'localhost'"
PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
echo "=> Creating MySQL admin user with random password"
mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

# The /initialize.sh file is used for commands necessary on each startup
echo "=> Running configuration scripts" 
if [ -f /initialize.sh ] ; then
  . /initialize.sh > /dev/null
fi
echo "=> Done!"
mysqladmin -uroot shutdown

echo "========================================================================"
echo "   ______   ____   ____  ____  ____  _________  ________  ";
echo "  |_   _ \`.|_  _| |_  _||_  _||_  _||  _   _  ||_   __  | ";
echo "    | | \`. \ \ \   / /    \ \  / /  |_/ | | \_|  | |_ \_| ";
echo "    | |  | |  \ \ / /      > \`' <       | |      |  _| _  ";
echo "   _| |_.' /   \ ' /     _/ /'\`\ \_    _| |_    _| |__/ | ";
echo "  |______.'     \_/     |____||____|  |_____|  |________| ";
echo "                                                            ";
echo "  Welcome to the Damn Vulnerable eXtensive Training Environment"
echo "  If you see no errors below everything is OK to go"
echo ""
echo "  Point your browser to http://localhost and start hacking!"
echo "========================================================================"

exec supervisord -n -c /etc/supervisor/supervisord.conf


