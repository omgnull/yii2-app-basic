#!/bin/bash

SELENIUM="selenium-server-standalone-2.53.0.jar"
SELENIUM_DIR="$HOME/.selenium"
SELENIUM_DOWNLOAD_URL="http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar"

function download {
    printf "Downloading Selenium server $SELENIUM_DOWNLOAD_URL\n"
    wget -O $1 $SELENIUM_DOWNLOAD_URL
}

# prepare selenium
mkdir -p $SELENIUM_DIR
if ! [ -f "$SELENIUM_DIR/$SELENIUM" ] ; then
    download "$SELENIUM_DIR/$SELENIUM"
fi

# run selenium
printf 'Starting Selenium server\n'
java -jar $SELENIUM_DIR/selenium-server-standalone-2.53.0.jar > /tmp/selenium.log 2> /tmp/selenium.error &

# wait for selenium
printf 'Waiting Selenium server to load\n'
until $(curl --output /dev/null --silent --head --fail http://localhost:4444/wd/hub); do
    printf '.'
    sleep 1
done
printf '\n'
printf 'Selenium server started\n'

timeout 10s sh -c\
  "while ! curl --silent http://localhost:4444/ > /dev/null; do
    echo \"Waiting for Selenium to start...\" && sleep 0.1;
  done"\
 || exit 1
