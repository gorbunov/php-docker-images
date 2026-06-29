FROM ogorbunov/php:7.4-fpm
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

RUN pecl install xdebug-3.1.6 \
    && docker-php-ext-enable xdebug
