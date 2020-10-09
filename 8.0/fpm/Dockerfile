FROM php:8.0-rc-fpm-buster
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

# base apt configuration
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    unzip libzip-dev ca-certificates wget \
    && apt-get autoremove -y

# unbuild extensions in single layer
RUN docker-php-source extract \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) opcache zip \
    && docker-php-ext-enable opcache \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && docker-php-source delete

# add pickle instead of pecl as layer
RUN wget https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar \
    && chmod +x pickle.phar \
    && mv pickle.phar /usr/bin/pickle

# pecl extensions
RUN pickle install redis \
    && docker-php-ext-enable redis

RUN mkdir /current
WORKDIR /current

CMD ["php"]
