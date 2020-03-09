#MAINTAINER jelvan-d

FROM debian:buster

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install nginx
COPY ./srcs/nginx.config /etc/nginx/sites-available/nginxconfig
RUN ln -s /etc/nginx/sites-available/nginxconfig /etc/nginx/sites-enabled/nginxconfig

EXPOSE 80 443 110

CMD service nginx start && bash

#Copy in certificates
#Tell your nginx config to look for certificate
#Install MariaDB
#Create DB (maybe at end)
#DL PHP.MyAdmin
#Create a config for PHP.MyAdmin and cpy it in
#DL WordPress && config with database
#Send mail
#Increase limits
#Make sure you have right permissions and ownership rights
#Start it ALL