create server backend1 foreign data wrapper mysql options 
(host 'mysql_backend1', database 'spider', user 'spider', password 'spider', port 3306);

create server backend2 foreign data wrapper mysql options 
(host 'mysql_backend2', database 'spider', user 'spider', password 'spider', port 3306);
