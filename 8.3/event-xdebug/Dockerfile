FROM ogorbunov/php:8.3-cli-xdebug
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
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install pcntl \
    && pecl install event \
    && docker-php-ext-enable --ini-name "zz-event.ini" event \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && docker-php-source delete
