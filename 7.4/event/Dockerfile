FROM ogorbunov/php:7.4-cli
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

RUN apt-get update && apt-get install \
    ntp ntpdate build-essential autoconf libtool libtool-bin automake uuid-dev pkg-config libssl-dev libevent-dev libevent-2.1-6 libevent-extra-2.1-6 libevent-openssl-2.1-6 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ulimit -n 10000
RUN pecl install event \
    && docker-php-ext-enable event
