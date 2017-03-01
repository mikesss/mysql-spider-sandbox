create table opportunities (
    id int,
    accountName varchar(20),
    name varchar(128),
    owner varchar(7),
    amount decimal(10,2),
    closeDate date,
    stageName varchar(11),
    primary key (id),
    key (accountName)
) engine=spider COMMENT='wrapper "mysql", table "opportunities"'
 PARTITION BY HASH (id)
(
    PARTITION pt1 COMMENT = 'srv "backend1"',
    PARTITION pt2 COMMENT = 'srv "backend2"'
);