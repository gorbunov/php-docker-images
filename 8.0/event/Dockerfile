FROM ogorbunov/php:8.0-cli
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

RUN pecl install event && \
    pecl install ds && \
    docker-php-ext-enable event ds