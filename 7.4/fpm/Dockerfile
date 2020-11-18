FROM php:7.4-fpm-buster
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

# base apt configuration
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    unzip libzip-dev ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# unbuild extensions in single layer
RUN docker-php-source extract \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) opcache zip \
    && docker-php-ext-enable opcache zip \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && docker-php-source delete

# pecl extensions
RUN pecl install redis \
    && docker-php-ext-enable redis

RUN mkdir /current
WORKDIR /current

STOPSIGNAL SIGQUIT
EXPOSE 9000
CMD ["php-fpm"]
