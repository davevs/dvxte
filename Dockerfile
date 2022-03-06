FROM debian:buster-slim
MAINTAINER Dave van Stein <dvanstein@qxperts.io>

# --- Set up base environment ---
ARG DEBIAN_FRONTEND noninteractive
# get the latest updates
RUN apt-get update
# build dependencies that will be removed later
ENV buildDeps=' \
      curl \ 
      wget \
      git \
      bzip2 \
	unzip \
      xz-utils \
      gnupg \
      g++ \
      make \
      libreadline-dev \
      libsqlite3-dev \      
      shared-mime-info \
      software-properties-common \
      zlib1g-dev \
      '
RUN apt-get install -y --no-install-recommends \
      $buildDeps

# --- Install DXTE boilerplate ---
# create intialize script and install required tools during boot
ENV WWW /var/www/html
RUN touch /initialize.sh 
RUN apt-get install -y --no-install-recommends \
      pwgen \
      supervisor 

# application dependencies
RUN apt-get install -y --no-install-recommends \
      dnsutils \
      iputils-ping \
      libmcrypt4    

# databases
RUN apt-get install -y --no-install-recommends \
      mariadb-server \
      sqlite3

# apache stack
RUN apt-get install -y --no-install-recommends \
      apache2    
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# perl stack
RUN apt-get install -y --no-install-recommends \
      libapache2-mod-perl2 \
      libcgi-pm-perl 

# php stack
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
RUN apt-get install -y --no-install-recommends \
      php \
      libmcrypt-dev \
      libapache2-mod-php \
      php-curl \
      php-mbstring \
      php-mysql \
      php-gd \
      php-pear \
      php-dev \
      php-xml

RUN curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get update
RUN apt-get install php7.3-mcrypt
# RUN pecl config-set php_ini /etc/php/7.3/apache2/php.ini
# RUN echo "" | pecl install mcrypt
RUN echo 'extension=mcrypt.so' >> /etc/php/7.3/apache2/php.ini \
&&  echo 'session.save_path = "/tmp"' >> /etc/php/7.3/apache2/php.ini \
&&  sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php/7.3/apache2/php.ini

# install python stack
RUN apt-get install -y --no-install-recommends \
      python3 \
      python3-pip \
      python3-setuptools

# install java stack
ENV RELEASE_JAVA https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
RUN curl -L ${RELEASE_JAVA} -o /tmp/java.tar.gz
RUN tar -xvf /tmp/java.tar.gz -C /usr/bin
ENV PATH "$PATH:/usr/bin/jdk-17.0.2/bin"
ENV JAVA_HOME /usr/bin/jdk-17.0.2
RUN rm /tmp/java.tar.gz

# Install nvm, node, and npm stack
ENV NODE_VERSION 12
ENV RELEASE_NVM https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh
RUN curl ${RELEASE_NVM} -o /tmp/install.sh \
&&  chmod +x /tmp/install.sh \
&&  /tmp/install.sh
ENV PATH "$PATH:/root/.nvm:/root/.nvm/versions/node/v12.22.10/bin"
RUN ln -s /root/.nvm/versions/node/v12.22.10/bin/node /usr/bin/node \
&&  ln -s /root/.nvm/versions/node/v12.22.10/bin/npm /usr/bin/npm \
&&  chmod +x /root/.nvm/nvm.sh \
&&  ln -s /root/.nvm/nvm.sh /usr/bin/nvm

# install ruby and rails
ENV RUBY_VERSION 2.6.5
ENV RAILS_VERSION 6.0.0
ENV PATH "$PATH:/root/.rbenv/bin:/root/.rbenv/plugins/ruby-build/bin:/root/.rbenv/libexec"
ENV PATH "$PATH:/root/.rbenv/versions/2.6.5:/root/.rbenv/shims"
RUN npm install --global yarn \
&&  git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
&&  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
&&  rbenv install ${RUBY_VERSION} \
&&  rbenv global ${RUBY_VERSION} \
&&  ln -s /root/.rbenv/versions/2.6.5/ruby /usr/bin/ruby \
&&  ln -s /root/.rbenv/shims/gem /usr/bin/gem \
&&  gem install bundler \
&&  gem install rails -v ${RAILS_VERSION}

# --- Install DXTE applications ---
# install & configure dvwa - php/mysql
ENV REPO_DVWA https://github.com/digininja/DVWA.git
RUN git clone ${REPO_DVWA} $WWW/dvwa \
&&  cp $WWW/dvwa/config/config.inc.php.dist $WWW/dvwa/config/config.inc.php \
&&  chmod -R 777 $WWW/dvwa/hackable/uploads $WWW/dvwa/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt \
&&  sed -i "s/public_key' ]  = ''/public_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/private_key' ] = ''/private_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/'default_security_level' ] = 'impossible'/'default_security_level' ] = 'low'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/'db_user' ]     = 'dvwa';/'db_user' ]     = 'admin';/g" $WWW/dvwa/config/config.inc.php \
&&  echo "sed -i \"s/p@ssw0rd/\$PASS/g\" $WWW/dvwa/config/config.inc.php" >> /initialize.sh

# install & configure NOWASP / mutillidae II - php/mysql
ENV REPO_NOWASP https://github.com/webpwnized/mutillidae.git
RUN git clone ${REPO_NOWASP} $WWW/mutillidae \
&& sed -i 's/MySQLDatabaseUsername = "root"/MySQLDatabaseUsername = "admin"/g' $WWW/mutillidae/classes/MySQLHandler.php \
&& sed -i "s/('DB_USERNAME', 'root')/('DB_USERNAME', 'admin')/g" $WWW/mutillidae/includes/database-config.inc \
&& echo "sed -i \"s/('DB_PASSWORD', 'mutillidae')/('DB_PASSWORD', '\$PASS')/g\" $WWW/mutillidae/includes/database-config.inc" >> /initialize.sh\
&& chmod +x $WWW/mutillidae/*.php

# install webmaven buggy bank
ENV RELEASE_WEBMAVEN https://www.mavensecurity.com/media/webmaven101.zip
RUN curl -kL ${RELEASE_WEBMAVEN} -o /tmp/webmaven.zip \
&& unzip /tmp/webmaven.zip -d /tmp/webmaven \
&& mv /tmp/webmaven/src/cgi-bin/* /usr/lib/cgi-bin/ \
&& mv /tmp/webmaven/src/wm /usr/lib/ \
&& mv /tmp/webmaven/src/webmaven_html/ $WWW/webmaven/ \
&& sed -i 's/perl/\/usr\/bin\/perl/g' /usr/lib/cgi-bin/wm.cgi \
&& sed -i "s/src=>'\//src=>'\/webmaven\//g" /usr/lib/cgi-bin/wm.cgi \
&& sed -i 's/SRC="..\//SRC="\/webmaven\//g' /usr/lib/cgi-bin/templates/* \
&& sed -i 's/HREF="..\//HREF="\/webmaven\//g' /usr/lib/cgi-bin/templates/* \
&& chmod +x /usr/lib/cgi-bin/wm.cgi \
&& chmod 777 /usr/lib/wm/ \
&& a2enmod cgi

# install webgoat & webwolf - java/instantDB
ENV RELEASE_WEBGOAT https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webgoat-server-8.2.2.jar
ENV RELEASE_WEBWOLF https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webwolf-8.2.2.jar
RUN mkdir $WWW/webgoat \
&&  curl -L ${RELEASE_WEBGOAT} -o $WWW/webgoat/webgoat.jar  \
&&  curl -L ${RELEASE_WEBWOLF} -o $WWW/webgoat/webwolf.jar 
 
# Install Juiceshop
ENV RELEASE_JUICESHOP https://github.com/juice-shop/juice-shop/releases/download/v13.2.2/juice-shop-13.2.2_node12_linux_x64.tgz
RUN curl -L ${RELEASE_JUICESHOP} -o /tmp/juiceshop.tgz \
&&  tar -xzf /tmp/juiceshop.tgz -C ${WWW} \
&&  mv $WWW/juice-shop* $WWW/juiceshop \
&&  rm -r /tmp/juiceshop.tgz

# install railsgoat rails/SQLite
ENV REPO_RAILSGOAT https://github.com/OWASP/railsgoat.git
RUN git clone ${REPO_RAILSGOAT} $WWW/railsgoat \
&&  cd $WWW/railsgoat \
&&  bundle install --without development test openshift mysql \
&&  echo "cd /var/www/html/railsgoat && rails db:setup" >> /initialize.sh

# install mailcatcher
RUN gem install mailcatcher

# install django.NV
ENV REPO_DJANGONV https://github.com/nVisium/django.nV.git
RUN git clone $REPO_DJANGONV $WWW/djangonv
# upgrade django version to play well with python 3.7
RUN sed -i 's/1.8.3/1.8.19/g' $WWW/djangonv/requirements.txt
RUN cd $WWW/djangonv \
&&  pip3 install -r requirements.txt \
&&  sed -i 's/python/python3/g' $WWW/djangonv/reset_db.sh \
&&  sed -i 's/python/python3/g' $WWW/djangonv/runapp.sh \
&&  sed -i 's/runserver/runserver 0.0.0.0:8000/g' $WWW/djangonv/runapp.sh \
&&  echo "cd /var/www/html/djangonv && ./reset_db.sh" >> /initialize.sh

# WrongSecrets
ENV RELEASE_WRONGSECRETS https://github.com/commjoen/wrongsecrets/releases/download/1.3.4/wrongsecrets-1.3.4-SNAPSHOT.jar
ENV ARG_BASED_PASSWORD="DVXTE IS COOL"
ENV SPRING_PROFILES_ACTIVE=without-vault
ENV APP_VERSION="1.3.4"
ENV DOCKER_ENV_PASSWORD="This is it"
ENV AZURE_KEY_VAULT_ENABLED=false
RUN mkdir $WWW/wrongsecrets \
&&  curl -L ${RELEASE_WRONGSECRETS} -o $WWW/wrongsecrets/wrongsecrets.jar

# install FileUploadLab
ENV REPO_FUL https://github.com/LunaM00n/File-Upload-Lab.git
RUN git clone $REPO_FUL /tmp/ful
RUN mv /tmp/ful/DVFU $WWW/ful

# install CryptOMG
# using own fork with php7 & mariaDB fixes
ENV REPO_CRYPTOMG https://github.com/davevs/CryptOMG.git
RUN git clone $REPO_CRYPTOMG $WWW/cryptomg
RUN sed -i "s/db_user = \"\";/db_user = \"admin\";/g" $WWW/cryptomg/includes/db.inc.php \
&&  echo "sed -i \"s/db_pass = \\\"\\\"/db_pass = \\\"\$PASS\\\"/g\" $WWW/cryptomg/includes/db.inc.php" >> /initialize.sh

# install DVGQL
ENV REPO_DVGQL https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application.git
RUN git clone $REPO_DVGQL $WWW/dvgql
RUN cd $WWW/dvgql \
&&  pip3 install -r requirements.txt \
&&  python3 setup.py
RUN sed -i 's/127.0.0.1/0.0.0.0/g' $WWW/dvgql/config.py
 
# # install dvws(ockets) - ratchet/reactphp
# install composer
# RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
# RUN cd /tmp \
# &&  php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# # install dvws(ockets) - ratchet/reactphp
# ENV REPO_DVWSOCK https://github.com/interference-security/DVWS.git
# RUN git clone ${REPO_DVWSOCK} $WWW/dvws \
# &&  cd $WWW/dvws \
# &&  composer install
# RUN echo "sed -i \"s/root/admin/g\" $WWW/dvws/includes/connect-db.php" >> /initialize.sh \ 
# &&  echo "sed -i \"s/dbpass = \\\"\\\"/dbpass = \\\"\$PASS\\\"/g\" $WWW/dvws/includes/connect-db.php" >> /initialize.sh \
# &&  echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /initialize.sh
# # convert hardcoded locations
# RUN sed -i s/wsl.local/localhost/g $WWW/dvws/g blind-sql-injection.php

# install dvws(ervices) - node
# ENV REPO_DVWSERV https://github.com/snoopysecurity/dvws-node.git
# RUN git clone ${REPO_DVWSERV} $WWW/dvws-node \
# &&  cd $WWW/dvws-node \
# &&  npm install --build-from-source
# RUN echo "sed -i \"s/<login>root<\/login>/<login>admin<\/login>/g\" $WWW/dvws-node/config.xml" >> /initialize.sh
# RUN echo "sed -i \"s/<password>mysecretpassword<\/password>/<password>\$PASS<\/password>/g\" $WWW/dvws-node/config.xml" >> /initialize.sh
# RUN echo "sed -i \"s/dvws.local/localhost/g\" $WWW/dvws-node/config.xml" >> /initialize.sh
# RUN echo "sed -i \"s/SQL_username=root/SQL_username=admin/g\" $WWW/dvws-node/.env" >> /initialize.sh
# RUN echo "sed -i \"s/SQL_password=mysecretpassword/SQL_password=\$PASS/g\" $WWW/dvws-node/.env" >> /initialize.sh
# RUN echo "sed -i \"s/dvws.local\/api/localhost:5000\/api/g\" $WWW/dvws-node/config.xml" >> /initialize.sh
# RUN echo "cd $WWW/dvws-node && node startup_script.js" >> /initialize.sh

# # cleanup
# RUN  apt-get purge -y $buildDeps \
# &&  apt-get autoremove -y \
# &&  apt-get clean -y \
# &&  rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /tmp/* /var/tmp/*

# --- Install DXTE startup files and landing page --- 
# Copy startup files and config files
COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
RUN  mkdir runfiles
COPY runfiles/* /runfiles/
COPY supervisor/* /etc/supervisor/conf.d/
COPY rootfiles/* /


# Set execution rights on startup scripts
RUN chmod +x /*.sh
RUN chmod +x /runfiles/*.sh

# copy landing page and redirect files
COPY www $WWW/

# port usage
#   80 - DVWA, Mutillidae, BuggyBank, CryptOMG, FUL
# 1080 - Mailcatcher
# 3000 - RailsGoat
# 3306 - mariaDB/MySQL
# 4000 - Juiceshop
# 5013 - DVGQL
# 8000 - django.NV
# 8200 - WebGoat
# 8300 - WebWolf
# 8400 - WrongSecrets
# 9000 - Supervisor dashboard
# 9001 - HSQLDB 

EXPOSE 80 1080 3000 4000 5013 8000 8200 8300 8400 9000

CMD ["/run.sh"]
