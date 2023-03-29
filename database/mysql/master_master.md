## Prepare
2 Server: 
  mysql1   123.31.39.10
  mysql2   123.31.39.100


## Setup

Setup on mysql1

```
CREATE USER 'linoxideleftuser1'@'123.31.39.100' IDENTIFIED WITH mysql_native_password BY 'replicatepass';
GRANT REPLICATION SLAVE ON *.* TO 'linoxideleftuser1'@'123.31.39.100';
show master status;
CHANGE MASTER TO MASTER_HOST = '123.31.39.100', MASTER_USER = 'linoxideleftuser1', MASTER_PASSWORD = 'replicatepass', MASTER_LOG_FILE = 'binlog.000007', MASTER_LOG_POS = 157;
```

Setup on mysql2
123.31.39.100
CREATE USER 'linoxideleftuser1'@'123.31.39.10' IDENTIFIED WITH mysql_native_password BY 'replicatepass';
GRANT REPLICATION SLAVE ON *.* TO 'linoxideleftuser1'@'123.31.39.10';
show master status;
CHANGE MASTER TO MASTER_HOST = '123.31.39.10', MASTER_USER = 'linoxideleftuser1', MASTER_PASSWORD = 'replicatepass', MASTER_LOG_FILE = 'binlog.000007', MASTER_LOG_POS = 157;