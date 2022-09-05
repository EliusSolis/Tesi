FROM php:7.2-apache

RUN apt update && apt install -y iproute2 iptables
COPY src/ /var/www/html/
