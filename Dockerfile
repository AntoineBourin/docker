FROM debian:buster
RUN apt-get update -yq \
&& apt-get upgrade -y \
&& apt-get install -y nginx \
&& chown -R www-data:www-data /var/lib/nginx
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install default-mysql-server
RUN apt-get install -y php7.3 php-fpm php-cgi php-mysqli php-pear php-mbstring php-gettext php-common php-phpseclib php-mysql
RUN apt install wget -y && \
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.zip && \
apt install unzip -y && \
unzip phpMyAdmin-4.9.0.1-all-languages.zip && \
mv phpMyAdmin-4.9.0.1-all-languages /usr/share/phpmyadmin && \
chown -R www-data:www-data /usr/share/phpmyadmin /var/www
RUN cd /usr/share/phpmyadmin && ls -la
RUN ln -s /usr/share/phpmyadmin/ /var/www/html/phpmyadmin
ADD ./srcs/nginx.conf /etc/nginx/sites-available/default
RUN service nginx reload
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
WORKDIR /srcs/
#RUN chmod 777 /run/php/php7.3-fpm.sock
RUN chmod 777 -R /var/www/html
RUN cd /var/www/html && echo "<?php phpinfo(); ?>" > index.php
COPY ./srcs/start.sh /start.sh
RUN chmod 777 /start.sh
COPY ./srcs/conf.sql /sqlconf.txt
RUN service mysql start && mysql -uroot mysql < "/sqlconf.txt"
RUN cd /var/www/html && mkdir wordpress
ADD ./srcs/wordpress /var/www/html/wordpress

EXPOSE 80
ENTRYPOINT "/start.sh"
