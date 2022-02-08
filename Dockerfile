FROM debian:jessie
MAINTAINER Dave van Stein <dvanstein@qxperts.io>

# --- URLs for packages ---
# Damn Vulnerable Web Application
ENV REPO_DVWA https://github.com/digininja/DVWA.git
# NOWASP / Mutillidea II
ENV REPO_NOWASP https://github.com/webpwnized/mutillidae.git
# Damn Vulnerbale Web Sockets
ENV REPO_DVWSOCK https://github.com/interference-security/DVWS.git
# Damn Vulnerable Web Serivces (original version)
ENV REPO_DVWSERV_OLD https://github.com/snoopysecurity/dvws.git
# Webgoat & Webwolf
ENV RELEASE_WEBGOAT https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webgoat-server-8.2.2.jar
ENV RELEASE_WEBWOLF https://github.com/WebGoat/WebGoat/releases/download/v8.2.2/webwolf-8.2.2.jar
# Juiceshop
ENV NODE_VERSION 14
ENV RELEASE_NVM https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh
ENV RELEASE_NODEJS https://nodejs.org/download/release/v12.22.10/node-v12.22.10-linux-x64.tar.gz
ENV REPO_JUICESHOP https://github.com/bkimminich/juice-shop.git
# Railsgoat
ENV RELEASE_RUBY http://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.3.tar.gz




# ----------------------------

# create intialize script for configuration items during boot
RUN touch /initialize.sh 

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

# Define temporary stuff
ENV DEBIAN_FRONTEND noninteractive
RUN buildDeps=' \
      autoconf \
      bison \
      bzip2 \
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
      zlib1g-dev \
      make \
      ruby \
	    unzip \
      wget \
      xz-utils \
      ' \
# Install packages
&& apt-get update \
&& apt-get install -y --no-install-recommends \
      $buildDeps \
      apache2 \
      default-jre-headless \
      libapache2-mod-php5 \
      libapache2-mod-perl2 \
      libcgi-pm-perl \
      libgdbm3 \
      libyaml-0-2 \
      mysql-server \
      nodejs \
      php5-mysql \
      php5-gd \
      procps \
      python3 \
      pwgen \
      sqlite3 \
      supervisor \
# get the latest updates
&& apt-get upgrade

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

# install & configure dvwa
RUN git clone ${REPO_DVWA} $WWW/dvwa \
&&  cp $WWW/dvwa/config/config.inc.php.dist $WWW/dvwa/config/config.inc.php \
&&  chmod -R 777 $WWW/dvwa/hackable/uploads $WWW/dvwa/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt \
&&  sed -i "s/public_key' ]  = ''/public_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/private_key' ] = ''/private_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/'default_security_level' ] = 'impossible'/'default_security_level' ] = 'low'/g" $WWW/dvwa/config/config.inc.php \
&&  echo "sed -i \"s/'db_user' ]     = 'dvwa';/'db_user' ]     = 'admin';/g\" $WWW/dvwa/config/config.inc.php" >> /initialize.sh \
&&  echo "sed -i \"s/p@ssw0rd/\$PASS/g\" $WWW/dvwa/config/config.inc.php" >> /initialize.sh

# install & configure NOWASP / mutillidae II
RUN git clone ${REPO_NOWASP} $WWW/mutillidae \
&& sed -i 's/MySQLDatabaseUsername = "root"/MySQLDatabaseUsername = "admin"/g' $WWW/mutillidae/classes/MySQLHandler.php \
&& sed -i "s/('DB_USERNAME', 'root')/('DB_USERNAME', 'admin')/g" $WWW/mutillidae/includes/database-config.inc \
&& echo "sed -i \"s/('DB_PASSWORD', 'mutillidae')/('DB_USERNAME', '\$PASS')/g\" $WWW/includes/database-config.inc" >> /initialize.sh\
&& chmod +x $WWW/mutillidae/*.php

# install & configure dvws(ockets)
RUN git clone ${REPO_DVWSOCK} $WWW/dvwsock \
&&  sed -i 's/root/admin/g' $WWW/dvwsock/includes/connect-db.php \ 
&&  echo "sed -i \"s/toor/\$PASS/g\" $WWW/dvwsock/includes/connect-db.php" >> /initialize.sh

# install dvws(ervices)
RUN git clone ${REPO_DVWSERV_OLD} $WWW/dvws

# install webgoat & webwolf
RUN mkdir $WWW/webgoat
ADD ${RELEASE_WEBGOAT} $WWW/webgoat/webgoat.jar
ADD ${RELEASE_WEBWOLF} $WWW/webgoat/webwolf.jar

# Install nvm, node, and npm
ADD ${RELEASE_NVM} /tmp/
RUN chmod +x /tmp/install.sh \
&& /tmp/install.sh
RUN ln -s /root/.nvm/nvm.sh /bin/nvm \
&&  ln -s /root/.nvm/versions/node/v14.19.0/bin/npm /bin/npm \
&&  ln -s /root/.nvm/versions/node/v14.19.0/bin/node /bin/node

# temp juiceshop install
ADD https://github.com/juice-shop/juice-shop/releases/download/v13.2.1/juice-shop-13.2.1_node14_linux_x64.tgz /tmp/juiceshop.tgz
RUN tar -xzf /tmp/juiceshop.tgz -C ${WWW} \
&& mv $WWW/juice-shop* $WWW/juiceshop \
&& rm -r /tmp/juiceshop.tgz

# install ruby, rail, and railsgoat
## skip installing gem documentation

ENV RUBYGEMS_VERSION 2.6.10
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
ENV BUNDLER_VERSION 1.14.4
ENV RAILS_VERSION 4
RUN mkdir -p /usr/local/etc \
&&    { \
        echo 'install: --no-document'; \
        echo 'update: --no-document'; \
      } >> /usr/local/etc/gemrc
ADD ${relaease_ruby} /tmp/ruby.tgz
RUN mkdir -p /usr/src/ruby \
&&  tar -xzf /tmp/rubytgz -C /usr/src/ruby --strip-components=1 \
&&  cd /usr/src/ruby \
&&  { \
        echo '#define ENABLE_PATH_CHECK 0'; \
        echo; \
        cat file.c; \
    } > file.c.new \
&&  mv file.c.new file.c \
&&  autoconf \
&& ./configure --disable-install-doc --enable-shared \
&&  make -j"$(nproc)" \
&&  make install \
&&  cd / \
&&  rm -r /usr/src/ruby \
&&  gem update --system "$RUBYGEMS_VERSION" \
&&  gem install bundler --version "$BUNDLER_VERSION" \
&&  mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
&&  chmod 777 "$GEM_HOME" "$BUNDLE_BIN" \
&&  gem install rails --version "$RAILS_VERSION" \
&&  git clone https://github.com/OWASP/railsgoat.git $WWW/railsgoat \
&&  cd $WWW/railsgoat \
&&  sed -i 's/2.2.2/2.2.3/' $WWW/railsgoat/Gemfile \
&&  bundle install \
&&  echo "cd /var/www/html/railsgoat && rake db:setup" >> /initialize.sh

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

# install RIPS
RUN wget "https://sourceforge.net/projects/rips-scanner/files/rips-0.55.zip/download?use_mirror=svwh" -O /tmp/rips.zip \
&& unzip /tmp/rips.zip -d $WWW

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
RUN  apt-get purge -y --auto-remove $buildDeps \
&&  apt-get clean -y \
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
# 4000 - Juiceshop~
# 8000 - django.NV
# 8080 - 
# 8200 - WebGoat
# 9090 - WebWolf
EXPOSE 80 1080 3000 4000 8000 8080 8200 9090

CMD ["/run.sh"]
