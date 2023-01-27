FROM php:8.2-fpm-bullseye
LABEL maintainer="Oleg Gorbunov <work@gorbunov.dev>"

# base apt configuration
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    unzip \
    libzip-dev \
    ca-certificates \
    wget \
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
    libicu-dev \
    libmemcached-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# unbuild extensions in single layer
RUN docker-php-source extract \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype \
    && docker-php-ext-install -j$(nproc) gd gmp bcmath intl pdo_mysql opcache zip \
    && docker-php-ext-enable opcache gmp bcmath gd intl \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && docker-php-source delete

# pecl extensions
RUN pecl install igbinary && \
    pecl install memcached && \
    pecl install redis && \
    pecl install ds && \
    docker-php-ext-enable igbinary memcached redis ds

COPY ./configs/8.2/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./configs/8.2/xdebug/zz-xdebug-docker.ini /usr/local/etc/php/conf.d/zz-xdebug-docker.ini

RUN mkdir /current
WORKDIR /current

EXPOSE 9000
EXPOSE 9003
CMD ["php-fpm"]
