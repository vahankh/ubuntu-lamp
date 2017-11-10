FROM ubuntu:16.04
MAINTAINER Vahan K 

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Install essentials
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl htop man unzip vim wget curl bash-completion

# Install Apache
RUN \
  apt-get install -y apache2 && \
  a2enmod rewrite && \
  mkdir -p /var/lock/apache2 /var/run/apache2  && \
  chown -R www-data /var/log/apache2

# Install MySQL
RUN apt-get install -y mysql-client

# Install PHP 7
RUN \
  apt-get install -y language-pack-en-base && \
  LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
  apt-get purge -y php5-common && \
  apt-get install -y php7.0 php7.0-dev php7.0-fpm php7.0-mysql php7.0-json php7.0-common php7.0-xml libapache2-mod-php7.0 && \
  a2enmod php7.0

# Install XDebug & Webgrind
RUN \
  apt-get install -y php-xdebug && \
  wget https://github.com/jokkedk/webgrind/archive/master.zip && \
  unzip master.zip && \
  rm -f master.zip && \
  mv webgrind-master /var/www/webgrind && \
  apt-get install -y python graphviz

COPY xdebug.ini /etc/php/7.0/apache2/conf.d/20-xdebug.ini
COPY 001-webgrind.conf /etc/apache2/sites-enabled/001-webgrind.conf
  
# Install Supervisord
RUN \ 
  apt-get install -y supervisor && \
  mkdir -p /var/log/supervisor
  
# Cleanup
RUN \
  rm -rf /var/lib/apt/lists/* && \
  apt-get --purge autoremove -y

COPY apache.supervisord.conf /etc/supervisor/conf.d/
COPY directory.conf /etc/apache2/conf-enabled/directory.conf

EXPOSE 80

CMD ["supervisord", "-n"]
