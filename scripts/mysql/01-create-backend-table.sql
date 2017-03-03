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
) engine=InnoDB;
