#!/bin/bash

if [ ! -d /var/run/mysqld ]; then

    echo 
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
    echo 'Success. Init process in progress...'
    echo

    ## SET UP SPIDER
    "${mysql[@]}" < /usr/local/mysql/share/install_spider.sql

    ## SET UP ROOT USER
    echo "GRANT ALL ON *.* TO 'root'@'%' ;" | "${mysql[@]}"

    ## CREATE DATABASE IF SPECIFIED
    if [ "$MYSQL_DATABASE" ]; then
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
        mysql+=( "$MYSQL_DATABASE" )
    fi

    ## CREATE NORMAL USER IF SPECIFIED
    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"

        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
        fi

        echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
    fi

    ## RUN ANY INIT SCRIPTS
    echo
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)     echo "$0: running $f"; . "$f" ;;
            *.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
            *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
            *)        echo "$0: ignoring $f" ;;
        esac
        echo
    done

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'Spider init failed.'
        exit 1
    fi

    echo
    echo 'Complete.  Ready for start up.'
    echo
fi

exec "$@"
