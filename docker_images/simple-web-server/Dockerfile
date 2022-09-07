FROM php:apache

RUN apt update && apt install -y iproute2

# Install Postgre PDO
RUN apt install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql
COPY src/ /var/www/html/
