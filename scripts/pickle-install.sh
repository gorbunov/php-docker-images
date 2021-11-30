#!/bin/sh

wget https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar -P /usr/local/bin
mv /usr/local/bin/pickle.phar /usr/local/bin/pickle
chmod +x /usr/local/bin/pickle