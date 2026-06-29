FROM ogorbunov/php:8.5-fpm
LABEL maintainer="Oleg Gorbunov <work@gorbunov.dev>"

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
