FROM ogorbunov/php:7.4-fpm
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1

COPY ./scripts/composer-install.sh /
RUN chmod +x /composer-install.sh \
    && /composer-install.sh \
    && rm /composer-install.sh
