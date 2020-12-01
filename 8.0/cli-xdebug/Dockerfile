FROM ogorbunov/php:8.0-cli
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
