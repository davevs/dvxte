FROM debian:jessie
MAINTAINER Dave van Stein <dvanstein@qxperts.io>

# --- Set up base environment ---
ENV DEBIAN_FRONTEND noninteractive
# add keyservers
RUN for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
  done 

# Install build environment and dependencies
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
      apache2 \
      autoconf \
      bison \
      build-essential \
      bzip2 \
      curl \
      default-jre-headless \
      g++ \
      gcc \
      git \
      libbz2-dev \
      libffi-dev \
      libgdbm-dev \
      libglib2.0-dev \
      libmysqlclient-dev \
      libncurses-dev \
      libreadline-dev \
      libsqlite3-dev \
      libxml2-dev \
      libxslt-dev \
      libapache2-mod-php5 \
      libapache2-mod-perl2 \
      libcgi-pm-perl \
      libcurl4-openssl-dev \
      libgdbm3 \
      libssl-dev \
      libyaml-dev \
      mysql-server \
      nodejs \
      php5-mysql \
      php5-gd \
      procps \
      python3 \
      pwgen \
      shared-mime-info \
      software-properties-common \
      sqlite3 \
      supervisor \
      make \
      ruby \
	    unzip \
      wget \
      xz-utils \
      zlib1g-dev \
# get the latest updates
&& apt-get upgrade

# --- Install DXTE ----
# create intialize script for configuration items during boot
RUN touch /initialize.sh 

# configure apache, php, mysql
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV WWW /var/www/html
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# php config
RUN sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/apache2/php.ini \
&&  echo 'session.save_path = "/tmp"' >> /etc/php5/apache2/php.ini
# Remove pre-installed mysql database and add password to startup script
RUN echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /initialize.sh

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
&& echo "sed -i \"s/('DB_PASSWORD', 'mutillidae')/('DB_PASSWORD', '\$PASS')/g\" $WWW/includes/database-config.inc" >> /initialize.sh\
&& chmod +x $WWW/mutillidae/*.php

# install & configure dvws(ockets) - php/mysql
ENV REPO_DVWSOCK https://github.com/interference-security/DVWS.git
RUN git clone ${REPO_DVWSOCK} $WWW/dvwsock \
&&  sed -i 's/root/admin/g' $WWW/dvwsock/includes/connect-db.php \ 
&&  echo "sed -i \"s/toor/\$PASS/g\" $WWW/dvwsock/includes/connect-db.php" >> /initialize.sh

# install dvws(ervices) - php/mysql
ENV REPO_DVWSERV_OLD https://github.com/snoopysecurity/dvws.git
RUN git clone ${REPO_DVWSERV_OLD} $WWW/dvws
RUN echo "sed -i \"s/('localhost', 'root', ''/('localhost', 'admin', '\$PASS'/g\" $WWW/dvws/instructions.php" >> /initialize.sh

# install webgoat & webwolf - java/instantDB
ENV RELEASE_WEBGOAT https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webgoat-server-8.2.2.jar
ENV RELEASE_WEBWOLF https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webwolf-8.2.2.jar
RUN mkdir $WWW/webgoat
RUN curl -L ${RELEASE_WEBGOAT} -o $WWW/webgoat/webgoat.jar 
RUN curl -L ${RELEASE_WEBWOLF} -o $WWW/webgoat/webwolf.jar 

# Install nvm, node, and npm
ENV NODE_VERSION 14
ENV RELEASE_NVM https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh
ENV RELEASE_NODEJS https://nodejs.org/download/release/v12.22.10/node-v12.22.10-linux-x64.tar.gz
RUN curl ${RELEASE_NVM} -o /tmp/install.sh
RUN chmod +x /tmp/install.sh \
&& /tmp/install.sh
ENV PATH "$PATH:/root/.nvm:/root/.nvm/versions/node/v14.19.0/bin"
RUN ln -s /root/.nvm/versions/node/v14.19.0/bin/node /usr/bin/node
RUN ln -s /root/.nvm/versions/node/v14.19.0/bin/npm /usr/bin/npm
RUN chmod +x /root/.nvm/nvm.sh
RUN ln -s /root/.nvm/nvm.sh /usr/bin/nvm

# temp juiceshop install - node/SQLlite
ENV RELEASE_JUICESHOP https://github.com/juice-shop/juice-shop/releases/download/v13.2.1/juice-shop-13.2.1_node14_linux_x64.tgz
RUN curl -L ${RELEASE_JUICESHOP} -o /tmp/juiceshop.tgz
RUN tar -xzf /tmp/juiceshop.tgz -C ${WWW} \
&& mv $WWW/juice-shop* $WWW/juiceshop \
&& rm -r /tmp/juiceshop.tgz

# install ruby and rails
RUN apt-get remove ruby -y
ENV RUBY_VERSION 2.6.5
ENV RAILS_VERSION 6.0.0
RUN npm install --global yarn
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
ENV PATH "$PATH:/root/.rbenv/bin:/root/.rbenv/plugins/ruby-build/bin:/root/.rbenv/libexec"
RUN rbenv install ${RUBY_VERSION}
RUN rbenv global ${RUBY_VERSION}
ENV PATH "$PATH:/root/.rbenv/versions/2.6.5:/root/.rbenv/shims"
RUN ln -s /root/.rbenv/versions/2.6.5/ruby /usr/bin/ruby 
RUN ln -s /root/.rbenv/shims/gem /usr/bin/gem
RUN gem install bundler
RUN gem install rails -v ${RAILS_VERSION}

# install railsgoat rails/SQLite
ENV REPO_RAILSGOAT https://github.com/OWASP/railsgoat.git
RUN git clone ${REPO_RAILSGOAT} $WWW/railsgoat
RUN cd $WWW/railsgoat \
&&  bundle install --without development test openshift mysql \
&&  echo "cd /var/www/html/railsgoat && rails db:setup" >> /initialize.sh

# install mailcatcher
RUN gem install mailcatcher

# BREAK FOR DEBUG
ADD https://foobar.xyzw .

# install django.NV
RUN wget https://bootstrap.pypa.io/get-pip.py -P /tmp \
&&  python3 /tmp/get-pip.py \
&&  git clone https://github.com/davevs/django.nV.git $WWW/djangonv \
&&  cd $WWW/djangonv \
&&  pip install -r requirements.txt \
&&  sed -i 's/python/python3/g' $WWW/djangonv/reset_db.sh \
&&  sed -i 's/python/python3/g' $WWW/djangonv/runapp.sh \
&&  sed -i 's/runserver/runserver 0.0.0.0:8000/g' $WWW/djangonv/runapp.sh \
&&  echo "cd /var/www/html/djangonv && ./reset_db.sh" >> /initialize.sh

# BREAK FOR DEBUG
ADD https://foobar.xyzw .

# install webmaven buggy bank
RUN wget https://www.mavensecurity.com/media/webmaven101.zip -P /tmp \
&& unzip /tmp/webmaven101.zip -d /tmp/webmaven \
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

# BREAK FOR DEBUG
ADD https://foobar.xyzw .

# cleanup
RUN  apt-get clean -y \
&&  apt-get autoclean -y \
&&  apt-get autoremove -y \
&&  rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /tmp/* /var/tmp/*

# Copy startup files and config files
COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
COPY startup/* /
COPY supervisor/* /etc/supervisor/conf.d/

# Set execution rights on startup scripts
RUN chmod +x /*.sh

# copy landing page and redirect files
COPY www $WWW/

# open ports
#   80 - DVWA, Mutillidae, DVWServices, DVWSockets, BuggyBank, Rips
# 1080 - Mailcatcher
# 3000 - RailsGoat
# 4000 - Juiceshop
# 8000 - django.NV
# 8080 - 
# 8200 - WebGoat
# 9090 - WebWolf
EXPOSE 80 1080 3000 4000 8000 8080 8200 9090

CMD ["/run.sh"]
