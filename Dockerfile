# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: vo-nguye <vo-nguye@42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/01/13 12:30:15 by vo-nguye          #+#    #+#              #
#    Updated: 2020/01/21 03:39:57 by vo-nguye         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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

# https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-debian-9
# https://www.digitalocean.com/community/tutorials/how-to-install-phpmyadmin-from-source-debian-10
# https://kifarunix.com/install-wordpress-5-with-nginx-on-debian-10-buster/amp/
# https://websiteforstudents.com/install-wordpress-4-9-on-ubuntu-17-04-7-10-with-nginx-mariadb-and-php/
# https://wordpress.org/support/article/how-to-install-wordpress/
# RUN wget https://wordpress.org/latest.tar.gz
# RUN mv latest.tar.gz wordpress.tar.gz && tar -zxvf wordpress.tar.gz && rm -rf wordress.tar.gz
# https://www.shellhacks.com/create-csr-openssl-without-prompt-non-interactive/

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


RUN wget https://wordpress.org/latest.tar.gz
RUN mv latest.tar.gz wordpress.tar.gz && tar -zxvf wordpress.tar.gz && rm -rf wordress.tar.gz

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=FR/ST=75/L=Paris/O=42/CN=vo-nguye' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
RUN chown -R www-data:www-data *
RUN chmod 755 -R *


COPY ./srcs/default /etc/nginx/sites-available/default
CMD service nginx start ; \
    service php7.3-fpm start ; \
    service mysql start ; \
    sleep infinity & wait

EXPOSE 80 443

# POUR LANCER LE CONTAINER :
# VERIFIER QUE RIEN NE TOURNE SUR LES PORTS 80 et 443, souvent c'est Nginx ou apache
# systemctl stop nginx
# docker build . -t eval_server:1
# docker run -p 80:80 -p 443:443 -d eval_server:1

# POUR MODIFIER L INDEX :
# docker exec -it ID_CONTAINER /bin/bash
# et modifier le fichier index.html

# NOTES POUR MOI MEME

# docker image prune
# docker container prune
# docker exec it CONTAINER_ID bash
# docker run --detach  :: Run container in background and print container id
# docker run -p  80:80 -p 443:443 -d IMAGE_ID
# docker stop container_id
# ps
# images
# ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
