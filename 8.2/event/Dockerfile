FROM ogorbunov/php:8.2-cli
LABEL maintainer="Oleg Gorbunov <work@gorbunov.dev>"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libssl-dev \
    openssl \
    libevent-dev  \
    libevent-2.1-7  \
    libevent-openssl-2.1-7 \
    && docker-php-source extract \
    && docker-php-ext-install sockets \
    && pecl install event \
    && docker-php-ext-enable --ini-name "zz-event.ini" event \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && docker-php-source delete
