#!/bin/bash

if [ ! -d /var/run/mysqld ]; then

    echo
    echo 'Initializing container.'
    echo 'Starting MySQL daemon.'
    echo

    mkdir -p /var/run/mysqld
    chown mysql /var/run/mysqld
    /usr/local/mysql/bin/mysqld --user=mysql --skip-networking --basedir=/usr/local/mysql --socket=/var/run/mysqld/mysqld.sock & 
    pid="$!"

    mysql=( /usr/local/mysql/bin/mysql --protocol=socket -uroot -hlocalhost --socket=/var/run/mysqld/mysqld.sock)

    # wait for mysqld to start
    for i in {30..0}; do
        if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
            break
        fi
        echo 'Waiting for MySQL...'
        sleep 1
    done

    echo
    echo 'Success. Spider init process in progress...'
    echo

    # run the spider init script
    "${mysql[@]}" < /usr/local/mysql/share/install_spider.sql

    echo
    echo 'Spider init complete.'
    echo 'Opening up MySQL root user priveleges.'
    echo

    echo "GRANT ALL ON *.* TO 'root'@'localhost'" | "${mysql[@]}"
    echo "GRANT ALL ON *.* TO 'root'@'%'" | "${mysql[@]}"

    echo
    echo 'Priveleges complete.'
    echo 'Shutting down MySQL'
    echo

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'Spider init failed.'
        exit 1
    fi

    echo
    echo 'Complete.  Ready for start up.'
    echo
fi

exec "$@"
