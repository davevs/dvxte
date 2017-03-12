FROM debian:jessie
MAINTAINER Dave van Stein <dvanstein@xebia.com>

# CONFIGURATION SETTINGS
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV WEBGOAT_VERSION 7.1
ENV WEBGOAT_FILE webgoat-container-$WEBGOAT_VERSION-exec.jar 
ENV WEBGOAT_URL https://github.com/WebGoat/WebGoat/releases/download/$WEBGOAT_VERSION/$WEBGOAT_FILE 
ENV WEBGOAT_FILE_SHA256 cc531e1e5d5b21394963f2a9bde00e83785ba1a94340bd13bde83dc24e23b77b
ENV WWW /var/www/html
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.10.0
ENV NODE_FILE_SHA256 0f28bef128ef8ce2d9b39b9e46d2ebaeaa8a301f57726f2eba46da194471f224
ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.3
ENV RUBY_FILE_SHA256 1a4fa8c2885734ba37b97ffdb4a19b8fba0e8982606db02d936e65bac07419dc 
ENV RUBYGEMS_VERSION 2.6.10
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
ENV BUNDLER_VERSION 1.14.4
ENV RAILS_VERSION 4
ENV PIP_FILE_SHA256 19dae841a150c86e2a09d475b5eb0602861f2a5b7761ec268049a662dbd2bd0c 
ENV RIPS_FILE_SHA256 8198e50cbdc9894583c5732ecc18c08a17f8aba60493d62e087f17eedcf13844
ENV WEBMAVEN_FILE_SHA256 3129075db3420158b79d786091a2813534b5e1080b89a21c15567746ae8d1f46 

# create intialize script for configuration items during boot
RUN touch /initialize.sh \

&& for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done \

# Define temporary stuff
&&  buildDeps=' \
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
      libssl-dev \
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
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
      $buildDeps \
      apache2 \
      ca-certificates \
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

# apache config
&&  echo "ServerName localhost" >> /etc/apache2/apache2.conf \
# php config
&&  sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/apache2/php.ini \
&&  echo 'session.save_path = "/tmp"' >> /etc/php5/apache2/php.ini \
# Remove pre-installed mysql database and add password to startup script
&&  echo "mysql -uadmin -p\$PASS -e \"CREATE DATABASE dvws_db\"" >> /initialize.sh \

# install & configure dvwa
&&  git clone https://github.com/ethicalhack3r/DVWA.git $WWW/dvwa \
&&  chmod -R 777 $WWW/dvwa/hackable/uploads $WWW/dvwa/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt \
&&  sed -i "s/public_key' ]  = ''/public_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/private_key' ] = ''/private_key' ] = 'TaQ185RFuWM'/g" $WWW/dvwa/config/config.inc.php \
&&  sed -i 's/root/admin/g' $WWW/dvwa/config/config.inc.php \
&&  sed -i "s/'default_security_level' ] = 'impossible'/'default_security_level' ] = 'low'/g" $WWW/dvwa/config/config.inc.php \
&&  echo "sed -i \"s/p@ssw0rd/\$PASS/g\" $WWW/dvwa/config/config.inc.php" >> /initialize.sh \

# install dvws(ervices)
&&  git clone https://github.com/snoopysecurity/dvws.git $WWW/dvws \

# install & configure dvws(ockets)
&&  git clone https://github.com/interference-security/DVWS.git $WWW/dvwsock \
&&  sed -i 's/root/admin/g' $WWW/dvwsock/includes/connect-db.php \ 
&&  echo "sed -i \"s/toor/\$PASS/g\" $WWW/dvwsock/includes/connect-db.php" >> /initialize.sh \

# install & configure NOWASP / mutillidae II
&& git clone git://git.code.sf.net/p/mutillidae/git $WWW/mutillidae \
&& sed -i 's/MySQLDatabaseUsername = "root"/MySQLDatabaseUsername = "admin"/g' $WWW/mutillidae/classes/MySQLHandler.php \
&& echo "sed -i \"s/MySQLDatabasePassword = \\\"\\\"/MySQLDatabasePassword = \\\"\$PASS\\\"/g\" $WWW/mutillidae/classes/MySQLHandler.php" >> /initialize.sh \
&& chmod +x $WWW/mutillidae/*.php \

# install webgoat
&&  mkdir $WWW/webgoat \
&&  wget $WEBGOAT_URL -P $WWW/webgoat/ -q --show-progress \
&&  echo "$WEBGOAT_FILE_SHA256 $WWW/webgoat/$WEBGOAT_FILE" | sha256sum -c - \

# install nodejs and juiceshop&&  
&&  git clone https://github.com/bkimminich/juice-shop.git $WWW/juiceshop \
&&  wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" -P /tmp/ \
&&  echo "$NODE_FILE_SHA256 /tmp/node-v$NODE_VERSION-linux-x64.tar.xz" | sha256sum -c - \
&&  tar -xJf /tmp/"node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
&&  ln -s /usr/local/bin/node /usr/local/bin/nodejs \
&&  cd $WWW/juiceshop \
&&  npm install --production --unsafe-perm \

# install ruby, rail, and railsgoat
## skip installing gem documentation
&&  mkdir -p /usr/local/etc \
&&    { \
        echo 'install: --no-document'; \
        echo 'update: --no-document'; \
      } >> /usr/local/etc/gemrc \
&&  wget "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" -P /tmp/ \
&&  echo "$RUBY_FILE_SHA256 /tmp/ruby-$RUBY_VERSION.tar.xz" | sha256sum -c - \
&&  mkdir -p /usr/src/ruby \
&&  tar -xJf /tmp/ruby-$RUBY_VERSION.tar.xz -C /usr/src/ruby --strip-components=1 \
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
&&  echo "cd /var/www/html/railsgoat && rake db:setup" >> /initialize.sh \

# install django.NV
&&  wget https://bootstrap.pypa.io/get-pip.py -P /tmp \
&&  echo "$PIP_FILE_SHA256 /tmp/get-pip.py" | sha256sum -c - \
&&  python3 /tmp/get-pip.py \
&&  git clone https://github.com/davevs/django.nV.git $WWW/djangonv \
&&  cd $WWW/djangonv \
&&  pip install -r requirements.txt \
&&  sed -i 's/python/python3/g' $WWW/djangonv/reset_db.sh \
&&  sed -i 's/python/python3/g' $WWW/djangonv/runapp.sh \
&&  sed -i 's/runserver/runserver 0.0.0.0:8000/g' $WWW/djangonv/runapp.sh \
&&  echo "cd /var/www/html/djangonv && ./reset_db.sh" >> /initialize.sh \

# install RIPS
&& wget "https://sourceforge.net/projects/rips-scanner/files/rips-0.55.zip/download?use_mirror=svwh" -O /tmp/rips.zip \
&&  echo "$RIPS_FILE_SHA256 /tmp/rips.zip" | sha256sum -c - \
&& unzip /tmp/rips.zip -d $WWW \

# install webmaven buggy bank
&& wget https://www.mavensecurity.com/media/webmaven101.zip -P /tmp \
&& echo "$WEBMAVEN_FILE_SHA256 /tmp/webmaven101.zip" | sha256sum -c - \
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
&& a2enmod cgi \

# cleanup
&&  apt-get purge -y --auto-remove $buildDeps \
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

EXPOSE 80 1080 3000 4000 8000 8080 8200

CMD ["/run.sh"]
