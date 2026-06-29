FROM ogorbunov/php:8.4-cli
LABEL maintainer="Oleg Gorbunov <work@gorbunov.dev>"

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
