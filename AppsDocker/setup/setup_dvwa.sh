#!/bin/bash

# this script downloads the latest DVWA
# it will modify the default installation with the following:
# add recaptcha keys
# set DB user to admin
# use the random Mysql password
# set default difficulty from impossible to low

chmod -R 777 /app/dvwa/hackable/uploads /app/dvwa/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/apache2/php.ini
sed -i "s/$_DVWA[ 'recaptcha_private_key' ] = ''/$_DVWA[ 'recaptcha_private_key' ] = 'TaQ185RFuWM'/g" /app/dvwa/config/config.inc.php
sed -i "s/$_DVWA[ 'recaptcha_public_key' ] = ''/$_DVWA[ 'recaptcha_public_key' ] = 'TaQ185RFuWM'/g" /app/dvwa/config/config.inc.php
sed -i 's/FileInfo/All/g' /etc/apache2/sites-available/000-default.conf
sed -i 's/root/admin/g' /app/dvwa/config/config.inc.php
sed -i 's/impossible/low/g' /app/dvwa/config/config.inc.php
echo "sed -i \"s/p@ssw0rd/\$PASS/g\" /app/dvwa/config/config.inc.php" >> /mysql-setup.sh
echo 'session.save_path = "/tmp"' >> /etc/php5/apache2/php.ini
