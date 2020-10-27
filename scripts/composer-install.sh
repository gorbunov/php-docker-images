#!/bin/sh

EXPECTED_CHECKSUM="$(curl -s https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo >&2 'ERROR: Invalid installer checksum'
  rm composer-setup.php
  exit 1
fi

php composer-setup.php --quiet --filename=composer --install-dir=/usr/local/bin
RESULT=$?
if [ $RESULT -eq 0 ]; then
  chmod +x /usr/local/bin/composer
fi
rm composer-setup.php
exit $RESULT
