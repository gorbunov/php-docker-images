FROM ogorbunov/php:8.0-fpm
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

RUN pickle install xdebug \
    && docker-php-ext-enable xdebug
