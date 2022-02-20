FROM debian:stretch-slim
MAINTAINER Dave van Stein <dvanstein@qxperts.io>

# --- Set up base environment ---
ARG DEBIAN_FRONTEND noninteractive

# Install build environment and dependencies
ENV buildDeps=' \
      autoconf \
      bison \
      build-essential \
      bzip2 \
      curl \ 
      default-libmysqlclient-dev \          
      g++ \
      gcc \
      git \
      libbz2-dev \
      libcurl4-openssl-dev \
      libffi-dev \
      libgdbm-dev \
      libglib2.0-dev \  
      libncurses-dev \
      libreadline-dev \
      libssl-dev \
      libsqlite3-dev \
      libxml2-dev \
      libxslt-dev \
      libyaml-dev \
      python3-pip \
      make \
	unzip \
      wget \
      xz-utils \
      zlib1g-dev \
      '
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
      $buildDeps \
      apache2 \
      dnsutils \
      iputils-ping \
      libapache2-mod-php \
      libapache2-mod-perl2 \
      libcgi-pm-perl \
      libgdbm3 \
      libtool \
      libxml2 \ 
      libyaml-0-2 \
      mysql-server \
      nodejs \
      php-curl \
      php-mbstring \
      php-mysql \
      php-gd \
      php-xml \
      procps \
      python3 \
      pwgen \
      shared-mime-info \
      software-properties-common \
      sqlite3 \
      supervisor 

# get the latest updates
RUN apt-get upgrade

# --- Install DXTE boilerplate ---
# create intialize script for configuration items during boot
ENV WWW /var/www/html
RUN touch /initialize.sh 

# configure apache, php, mysql
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
# php config
&&  sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php/7.0/apache2/php.ini \
&&  echo 'session.save_path = "/tmp"' >> /etc/php/7.0/apache2/php.ini

# install java
ENV RELEASE_JAVA https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
RUN curl -L ${RELEASE_JAVA} -o /tmp/java.tar.gz
RUN tar -xvf /tmp/java.tar.gz -C /usr/bin
ENV PATH "$PATH:/usr/bin/jdk-17.0.2/bin"
ENV JAVA_HOME /usr/bin/jdk-17.0.2
RUN echo 'export PATH="/usr/bin/jdk-17.0.2/bin:$PATH"' >> ~/.bashrc \
&&  echo 'export JAVA_HOME=/usr/bin/jdk-17.0.2' >> ~/.bashrc \
&&  rm /tmp/java.tar.gz

# Install nvm, node, and npm
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
&&  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc \
&&  echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
&&  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
&&  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc \
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
&&  echo "sed -i \"s/'db_user' ]     = 'dvwa';/'db_user' ]     = 'admin';/g\" $WWW/dvwa/config/config.inc.php" >> /initialize.sh \
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




# --- to fix ---

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

# # Remove pre-installed mysql database and add password to startup script
# &&  echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /initialize.sh

# install django.NV
RUN git clone https://github.com/davevs/django.nV.git $WWW/djangonv \
&&  cd $WWW/djangonv \
&&  pip3 install -r requirements.txt \
&&  sed -i 's/python/python3/g' $WWW/djangonv/reset_db.sh \
&&  sed -i 's/python/python3/g' $WWW/djangonv/runapp.sh \
&&  sed -i 's/runserver/runserver 0.0.0.0:8000/g' $WWW/djangonv/runapp.sh \
&&  echo "cd /var/www/html/djangonv && ./reset_db.sh" >> /initialize.sh

# --- Install DXTE startup files and landing page --- 
# Copy startup files and config files
COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
COPY startup/* /
COPY supervisor/* /etc/supervisor/conf.d/

# Set execution rights on startup scripts
RUN chmod +x /*.sh

# copy landing page and redirect files
COPY www $WWW/

# port usage
#   80 - DVWA, Mutillidae, DVWServices, , BuggyBank
# 1080 - Mailcatcher
# 3000 - RailsGoat
# 3306 - mariaDB/MySQL
# 4000 - Juiceshop
# 5000 - dvws-node
# 8000 - django.NV
# 8080 - DVWServices
# 8200 - WebGoat
# 8300 - WebWolf
# 9001 - HSQLDB 
# 9090 - DVWSockets xmlrpc


EXPOSE 80 1080 3000 4000 5000 8000 8080 8200 8300 9090

CMD ["/run.sh"]
