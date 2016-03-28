#!/bin/bash

PHP_VERSION=$(phpenv version-name)
PHP_BIN="$HOME/.phpenv/versions/$PHP_VERSION/sbin/php-fpm"
NGINX_DIR="$HOME/nginx"

function replace_vars {
    sed -i \
        -e "s|%NGINX_DIR%|$NGINX_DIR|g" \
        -e "s|%TRAVIS_BUILD_DIR%|$TRAVIS_BUILD_DIR|g" \
        $1
}

# setup php-fpm
printf "Starting php-pfm daemon\n"
cp "$HOME/.phpenv/versions/$PHP_VERSION/etc/php-fpm.conf.default" "$HOME/.phpenv/versions/$PHP_VERSION/etc/php-fpm.conf"
echo "short_open_tag = On" >> "$HOME/.phpenv/versions/$PHP_VERSION/etc/php.ini"
# run php-fpm
"$PHP_BIN"

# setup nginx
printf "Move Nginx setup from $TRAVIS_BUILD_DIR/config/travis/nginx to $NGINX_DIR\n"
if [ mv "$TRAVIS_BUILD_DIR/config/travis/nginx" $NGINX_DIR ]; then
    printf "Done\n" ; else
    exit 1
fi

replace_vars "$NGINX_DIR/nginx.conf"
replace_vars "$NGINX_DIR/conf.d/condom-shop.test.conf"

# run nginx
printf "Starting Nginx daemon\n"
nginx -c "$NGINX_DIR/nginx.conf" -p $NGINX_DIR

