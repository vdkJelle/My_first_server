FROM debian:buster

RUN apt-get update
#RUN add-apt-repository universe

#RUN apt-get -y upgrade

RUN apt-get -y install \
	mariadb-server \
	nginx \
	php-fpm \
	php-mysql
	
COPY ./srcs/nginx.config /etc/nginx/sites-available/nginxconfig
#COPY ./srcs/php.config /etc/nginx/sites-available/phpconfig
COPY ./srcs/index.php /var/www/html
RUN ln -s /etc/nginx/sites-available/nginxconfig /etc/nginx/sites-enabled/nginxconfig
#RUN ln -s /etc/nginx/sites-available/phpconfig /etc/nginx/sites-enabled/phpconfig
#RUN unlink /etc/nginx/sites-enabled/default

EXPOSE 80 443 110

CMD service nginx start && bash
