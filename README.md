# mysql-spider-sandbox
This is a simple sandbox to play around with the MySQL spider engine.  

## Overview
- MySQL 5.5
- Spider 3.2
- Docker latest stable

The compose file will spin up three containers: one Spider-enabled MySQL container, and two vanilla MySQL containers. The two vanilla containers serve as the data backends for the Spider container.  There is no attempt at or attention paid to data persistence or security, so please don't attempt to use this for anything real.

The Spider MySQL server is initialized with server references to the two vanilla MySQL servers.  It also contains a table at `spider.opportunities` that is sharded between the two MySQL instances, and more generally it is pulled from an [example](https://mariadb.com/kb/en/mariadb/spider-use-cases/#use-case-2-sharding-by-hash) in MariaDB's documentation.  See more at the initializations scripts in `scripts/spider`.  The overall pattern for how this container is initialized is based off of how the official MySQL docker images perform their initialization.

The vanilla MySQL instances have corresponding InnoDB tables that store the actual data. See more in `scripts/mysql`.

The Spider MySQL server also has its `general_log` enabled, so you can observe what the Spider engine is doing by monitoring `mysql.general_log`.

The Spider and two MySQL instances expose themselves on ports `3307`, `3308`, and `3309` respectively.  The server at `3307` is the one you should connect to in order to mess around with the Spider engine, but connecting to `3308` and `3309` will allow you to check how the data is sharding.

All MySQL servers have a user named `spider` with password `spider`.

## How to Build
Simply run:

```
docker-compose build
```

This step will take some time the first go-around, as the `mysql_spider` image requires that both MySQL and Spider be built from source.

## How to Run
```
docker-compose up
```

Again, if these images are being run for the first time (either after the above initial build step, or after
removing pre-existing containers manually), this will take a little bit of time as all 3 containers will
initialize themselves/the database.

## Playing around with the containers
Simply connect your MySQL client with the following credentials:

```
mysql -h127.0.0.1 -P3307 -uspider -pspider
```

The `spider` database is already set up with a Spider table to mess around with, though you don't need to use it.

## Spider resources
The following resources were used while working on this:

- [SpiderForMySQL Official Site](http://spiderformysql.com) - You can download the official documentation from here.
- [MariaDB Spider documentation](https://mariadb.com/kb/en/mariadb/spider/) - MariaDB includes native support for Spider, and their documentation for it is excellent and largely applicable to SpiderForMySQL.
- [Kentoku presentations](https://www.slideshare.net/Kentoku) - Various slide presentations from the author of Spider.  Some are in Japanese.
- [Two-phase commit protocol - Wikipedia](https://en.wikipedia.org/wiki/Two-phase_commit_protocol) - Good overview of XA transactions, which are at the core of Spider's transaction support.
- [MySQL :: MySQL 5.7 Reference Manual :: 14.3.7 XA Transactions](https://dev.mysql.com/doc/refman/5.7/en/xa.html) -- Overview of the XA transaction syntax.