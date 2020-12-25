FROM debian:buster

RUN apt-get -y update && apt-get -y upgrade

# tools + LEMP

RUN apt-get install -y apt-utils
RUN apt-get install -y nano
RUN apt-get install -y wget
RUN	apt-get install -y nginx
RUN apt-get install -y mariadb-server mariadb-client
RUN apt-get install -y php-fpm php-mysql php-cli
RUN apt-get install -y php-mbstring php-zip php-gd

# sources 
COPY ./srcs/mysql_setup.sql /var/
RUN chmod -R 755 /var/lib/mysql/
RUN /etc/init.d/mysql start
RUN service mysql start && mysql -u root mysql < /var/mysql_setup.sql

# INSTALL PHPMYADMIN
WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-english.tar.gz
RUN tar xf phpMyAdmin-4.9.1-english.tar.gz && rm -rf phpMyAdmin-4.9.1-english.tar.gz
RUN mv phpMyAdmin-4.9.1-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

WORKDIR /var/www/html
RUN rm -rf index*
COPY ./srcs/index.html /var/www/html/index.html
COPY ./srcs/files /var/www/html/files

RUN wget https://wordpress.org/latest.tar.gz
RUN mv latest.tar.gz wordpress.tar.gz && tar -zxvf wordpress.tar.gz && rm -rf wordress.tar.gz

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=FR/ST=75/L=Paris/O=42/CN=vo-nguye' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
RUN chown -R www-data:www-data *
RUN chmod 755 -R *

COPY ./srcs/wp-config.php /var/www/html/wordpress/wp-config.php
COPY ./srcs/default /etc/nginx/sites-available/default

EXPOSE 80 443

ENV INDEX on


CMD sed -i "s/XXXXX/autoindex $INDEX;/g" /etc/nginx/sites-available/default ; \
	service nginx start ; \
    service php7.3-fpm start ; \
    service mysql start ; \
    sleep infinity & wait

# POUR LANCER LE CONTAINER :
# VERIFIER QUE RIEN NE TOURNE SUR LES PORTS 80 et 443, souvent c'est Nginx ou apache
# systemctl stop nginx
# docker build . -t vo:1
# docker run --env INDEX=off -p 80:80 -p 443:443 -d vo:1
