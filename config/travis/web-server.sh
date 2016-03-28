#!/bin/bash

PHP_VERSION=$(phpenv version-name)
PHP_BIN="$HOME/.phpenv/versions/$PHP_VERSION/sbin/php-fpm"
NGINX_DIR="$HOME/nginx"

function replace_vars {
    sed \
        -e "s|%NGINX_DIR%|$NGINX_DIR|g" \
        -e "s|%TRAVIS_BUILD_DIR%|$TRAVIS_BUILD_DIR|g" \
        $1
}

# setup php-fpm
cp "$HOME/.phpenv/versions/$PHP_VERSION/etc/php-fpm.conf.default" "$HOME/.phpenv/versions/$PHP_VERSION/etc/php-fpm.conf"
echo "short_open_tag = On" >> "$HOME/.phpenv/versions/$PHP_VERSION/etc/php.ini"
# run php-fpm
"$PHP_BIN"

# setup nginx
printf "$TRAVIS_BUILD_DIR/config/travis/nginx"
ls -al "$TRAVIS_BUILD_DIR/config/travis/nginx"
printf "$TRAVIS_BUILD_DIR/config/travis/nginx $NGINX_DIR"
mv "$TRAVIS_BUILD_DIR/config/travis/nginx" $NGINX_DIR
ls -al $NGINX_DIR
replace_vars "$NGINX_DIR/nginx.conf"
replace_vars "$NGINX_DIR/conf.d/condom-shop.test.conf"

# run nginx
nginx -c "$NGINX_DIR/nginx.conf"

