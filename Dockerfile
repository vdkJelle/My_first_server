FROM debian:buster

RUN apt-get update

RUN apt-get -y install \
	mariadb-server \
	nginx \
	wget \
	php7.3-fpm php7.3-cli php7.3-mysql php7.3-gd php7.3-imagick php7.3-recode php7.3-tidy php7.3-xmlrpc php7.3-mbstring \
	sendmail
	
COPY ./srcs/nginx.config /etc/nginx/sites-available/nginxconfig
COPY ./srcs/key.key /etc/ssl/certs/key.key
COPY ./srcs/certificate.crt /etc/ssl/certs/certificate.crt

RUN ln -s /etc/nginx/sites-available/nginxconfig /etc/nginx/sites-enabled/nginxconfig && nginx -t

WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz
RUN tar xf phpMyAdmin-5.0.2-english.tar.gz && rm phpMyAdmin-5.0.2-english.tar.gz
RUN mv phpMyAdmin-5.0.2-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

RUN service mysql start && \
	echo "CREATE DATABASE wordpress_db;" | mysql -u root && \
	echo "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'username'@'localhost' IDENTIFIED BY 'password';" | mysql -u root && \
	echo "GRANT SELECT, INSERT, DELETE, UPDATE ON phpmyadmin.* TO 'root'@'localhost';" | mysql -u root && \
	echo "FLUSH PRIVILEGES" | mysql -u root && \
	echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp
RUN wp cli update
RUN mkdir wordpress
WORKDIR /var/www/html/wordpress
RUN wp core download --allow-root && \
	service mysql start && \
	wp core config --allow-root --dbname=wordpress_db --dbuser=username --dbpass=password && \
	echo "define( 'WP_DEBUG', true );" >> /var/www/html/wordpress/wp-config.php && \
	echo "define( 'WP_DEBUG_LOG', true );" >> /var/www/html/wordpress/wp-config.php && \
	mysql < /var/www/html/phpmyadmin/sql/create_tables.sql && \
	wp core install --allow-root --url=https://localhost/wordpress --title=CodyWorship --admin_user=jelle --admin_password=password --admin_email=vdkjelle@gmail.com

RUN	sed -i '/upload_max_filesize/c upload_max_filesize = 20M' /etc/php/7.3/fpm/php.ini
RUN	sed -i '/post_max_size/c post_max_size = 21M' /etc/php/7.3/fpm/php.ini

RUN chown -R www-data:www-data /var/www
RUN chmod 755 -R /var/www

EXPOSE 80 443

CMD service php7.3-fpm start && \
	service nginx start && \
	service mysql start && \
	service sendmail start && \
	bash

# Run docker in detached mode (replace bash):
#	tail -f /dev/null

# Turn autoindex off in interactive mode: 
#   cd /etc/nginx/sites-available/ && sed -i 's/autoindex on/autoindex off/g' nginxconfig
#   service nginx restart
