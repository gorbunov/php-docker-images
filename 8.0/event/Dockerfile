FROM ogorbunov/php:8.0-cli
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

RUN pecl install event \
    && docker-php-ext-enable event
