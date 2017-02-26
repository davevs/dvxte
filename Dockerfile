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
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.10.0

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done && \
# Install packages
    apt-get update && \
    apt-get -y install \
# temporary stuff
      git \
	    wget \
	    xz-utils \
# necessary stuff
      pwgen \
      supervisor \
      apache2 \
      libapache2-mod-php5 \
      mysql-server \
      php5-mysql \
	    php5-gd \
	    default-jre-headless && \

# apache config
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
# php config
    sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/apache2/php.ini && \
    echo 'session.save_path = "/tmp"' >> /etc/php5/apache2/php.ini && \
# Remove pre-installed mysql database and add password to startup script
    rm -rf /var/lib/mysql/* && \
    echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /mysql-setup.sh && \

# install & configure dvwa
    git clone https://github.com/davevs/DVWA.git $WWW/dvwa && \
	  chmod -R 777 $WWW/dvwa/hackable/uploads $WWW/dvwa/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt && \
    sed -i "s/public_key' ]  = ''/public_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php && \
    sed -i "s/private_key' ] = ''/private_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php && \
    sed -i 's/root/admin/g' $WWW/dvwa/config/config.inc.php && \
    sed -i "s/'default_security_level' ] = 'impossible'/'default_security_level' ] = 'low'/g" $WWW/dvwa/config/config.inc.php && \
    echo "sed -i \"s/p@ssw0rd/\$PASS/g\" $WWW/dvwa/config/config.inc.php" >> /mysql-setup.sh && \

# install dvws(ervices)
    git clone https://github.com/davevs/dvws-1.git $WWW/dvws && \

# install & configure dvws(ockets)
    git clone https://github.com/davevs/DVWS.git $WWW/dvwsock && \
    sed -i 's/root/admin/g' $WWW/dvwsock/includes/connect-db.php && \ 
    echo "sed -i \"s/toor/\$PASS/g\" $WWW/dvwsock/includes/connect-db.php" >> /mysql-setup.sh && \    

# install webgoat
    mkdir $WWW/webgoat/ && \
    wget $WEBGOAT_URL && \
    mv $WEBGOAT_FILE $WWW/webgoat/webgoat.jar && \

# install nodejs and juiceshop    
	  git clone https://github.com/davevs/juice-shop.git $WWW/juiceshop && \
    wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    cd $WWW/juiceshop && \
    npm install --production --unsafe-perm && \

# cleanup
    apt-get purge -y --auto-remove git wget xz-utils && \
    apt-get clean -y && \
	  apt-get autoclean -y && \
	  apt-get autoremove -y && \
	  rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /tmp/* /var/tmp/*     
    
# Copy webfiles, startup files and config files
COPY www $WWW/
COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
COPY startup/* /
COPY supervisor/* /etc/supervisor/conf.d/

# Set execution rights on startup scripts
RUN chmod +x /*.sh

EXPOSE 80 4000 8080 8200
CMD ["/run.sh"]
