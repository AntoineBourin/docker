FROM debian:buster
RUN apt-get update -yq \
&& apt-get upgrade -y \
&& apt-get install -y nginx \
&& echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
chown -R www-data:www-data /var/lib/nginx
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install default-mysql-server
RUN service mysql start && mysql -u root -proot
RUN apt-get install -y php7.3 php-fpm php-cgi php-mysqli php-pear php-mbstring php-gettext php-common php-phpseclib php-mysql
RUN apt install wget -y && \
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.zip && \
apt install unzip -y && \
unzip phpMyAdmin-4.9.0.1-all-languages.zip && \
mv phpMyAdmin-4.9.0.1-all-languages /usr/share/phpmyadmin && \
chown -R www-data:www-data /usr/share/phpmyadmin
RUN cd /usr/share/phpmyadmin && ls -la
RUN ln -s /usr/share/phpmyadmin/ /var/www/html/phpmyadmin
ADD ./default /etc/nginx/sites-available/
RUN service nginx reload
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
RUN service php7.3-fpm start
RUN cd /etc/php/7.3/fpm && \
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' php.ini
RUN cd /etc/php/7.3/fpm/pool.d && \
sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 0.0.0.0:9000/g' www.conf && cat www.conf | grep "listen" && sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 0.0.0.1/g' www.conf
RUN cd /var/www/html && touch index.php && echo "<?php phpinfo();" > index.php && ls -la && usermod -a -G www-data root
RUN phpdismod xdebug
RUN service nginx reload && service php7.3-fpm restart
RUN ls /var/run/php*/**.sock
WORKDIR /srcs/
RUN service php7.3-fpm start && service php7.3-fpm status
EXPOSE 80
EXPOSE 8080

CMD ["nginx"]