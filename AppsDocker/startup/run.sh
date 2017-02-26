#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

echo "========================================================================"
echo "   ______   ____   ____  ____  ____  _________  ________  ";
echo "  |_   _ \`.|_  _| |_  _||_  _||_  _||  _   _  ||_   __  | ";
echo "    | | \`. \ \ \   / /    \ \  / /  |_/ | | \_|  | |_ \_| ";
echo "    | |  | |  \ \ / /      > \`' <       | |      |  _| _  ";
echo "   _| |_.' /   \ ' /     _/ /'\`\ \_    _| |_    _| |__/ | ";
echo "  |______.'     \_/     |____||____|  |_____|  |________| ";
echo "                                                            ";
echo "  Welcome to the Damn Vulnerable Xebia Training Environment"
echo ""
echo "  Point your browser to http://localhost and start hacking!"
echo "========================================================================"

exec supervisord -n
