FROM ogorbunov/php:7.4-event
LABEL maintainer="Oleg Gorbunov <dev.oleg.gorbunov@gmail.com>"

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1

COPY ./scripts/composer-install.sh /
RUN chmod +x /composer-install.sh \
    && /composer-install.sh \
    && rm /composer-install.sh

# base apt configuration
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    apt-transport-https software-properties-common git-core openssh-client gnupg \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" \
    && apt-get update \
    && apt-get install -y \
       docker-ce \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
