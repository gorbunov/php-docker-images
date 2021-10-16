FROM php:7.4-cli-buster
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

# base apt configuration
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        unzip \
        libzip-dev \
        libmagickwand-dev \
        libgmp3-dev \
        libbz2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libpng-dev \
        libxpm-dev \
        libwebp-dev \
        libvpx-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# unbuild extensions in single layer
RUN docker-php-source extract \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype \
    && docker-php-ext-install -j$(nproc) bcmath gmp pdo_mysql opcache zip \
    && docker-php-ext-enable opcache gmp bcmath \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && docker-php-source delete

# pecl extensions
RUN pecl install redis && \
    pecl install imagick && \
    pecl install ds && \
    pecl install igbinary && \
    docker-php-ext-enable igbinary redis imagick

RUN mkdir /current
WORKDIR /current

CMD ["php"]