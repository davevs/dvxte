FROM debian:jessie
MAINTAINER Dave van Stein <dvanstein@xebia.com>

# CONFIGURATION SETTINGS
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV WEBGOAT_VERSION 7.0.1
ENV WEBGOAT_FILE webgoat-container-$WEBGOAT_VERSION-war-exec.jar 
ENV WEBGOAT_URL https://github.com/WebGoat/WebGoat/releases/download/$WEBGOAT_VERSION/$WEBGOAT_FILE 
ENV WWW /var/www/html

# Install packages
RUN apt-get update && \
    apt-get -y install \
      pwgen \
	  git \
	  wget \
      supervisor \
      apache2 \
      libapache2-mod-php5 \
      mysql-server \
      php5-mysql \
	  php5-gd \
	  default-jre-headless && \
# Download files
    git clone https://github.com/davevs/DVWA.git $WWW/dvwa && \
    git clone https://github.com/davevs/dvws-1.git $WWW/dvws && \
    git clone https://github.com/davevs/DVWS.git $WWW/dvwsock && \
    mkdir $WWW/webgoat/ && \
    wget $WEBGOAT_URL && \
    mv $WEBGOAT_FILE $WWW/webgoat/webgoat.jar && \
# cleanup
    apt-get clean -y && \
	apt-get autoclean -y && \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /usr/share/doc/* 

# Copy webfiles, startup files and config files
COPY www $WWW/
COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
COPY startup/* /
COPY supervisor/* /etc/supervisor/conf.d/

# FINAL CONFIGURATION 
# Set execution rights on scripts
RUN chmod +x /*.sh && \
# apache config
   echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
# php config
    sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/apache2/php.ini && \
    echo 'session.save_path = "/tmp"' >> /etc/php5/apache2/php.ini && \
# Remove pre-installed mysql database and add password to startup script
    rm -rf /var/lib/mysql/* && \
    echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /mysql-setup.sh && \
#install dvwa
	chmod -R 777 $WWW/dvwa/hackable/uploads $WWW/dvwa/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt && \
    sed -i "s/public_key' ]  = ''/public_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php && \
    sed -i "s/private_key' ] = ''/private_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php && \
    sed -i 's/root/admin/g' $WWW/dvwa/config/config.inc.php && \
    sed -i "s/'default_security_level' ] = 'impossible'/'default_security_level' ] = 'low'/g" $WWW/dvwa/config/config.inc.php && \
    echo "sed -i \"s/p@ssw0rd/\$PASS/g\" $WWW/dvwa/config/config.inc.php" >> /mysql-setup.sh && \
#install dvws(ervices)
#install dvws(ockets)
    sed -i 's/root/admin/g' $WWW/dvwsock/includes/connect-db.php && \ 
    echo "sed -i \"s/toor/\$PASS/g\" $WWW/dvwsock/includes/connect-db.php" >> /mysql-setup.sh && \
# final cleanup when done
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

EXPOSE 80 8080 8200
CMD ["/run.sh"]
