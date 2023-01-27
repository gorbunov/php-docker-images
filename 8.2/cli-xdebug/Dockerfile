FROM ogorbunov/php:8.2-cli
LABEL maintainer="Oleg Gorbunov <work@gorbunov.dev>"

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
