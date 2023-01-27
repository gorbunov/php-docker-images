FROM ogorbunov/php:8.2-cli
LABEL maintainer="Oleg Gorbunov <work@gorbunov.dev>"

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
    apt-transport-https software-properties-common rsync git-core openssh-client gnupg gnupg-agent \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       docker-ce-cli \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
