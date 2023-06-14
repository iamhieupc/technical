## Install mysql
```
sudo apt install mysql-server
sudo systemctl start mysql.service
```

Start service mysql
```
sudo systemctl start mysql.service
```

## Config

Login to mysql as root
```
sudo mysql
```
 
Set password is <b>password</b> with user 'root'@'localhost'
```
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```

If you want login as sudo and non password, excute command
```
ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;
```

If you want to secure for password
```
sudo mysql_secure_installation
```

## Creating a Dedicated MySQL User and Granting Privileges

Create user
```
CREATE USER 'username'@'10.3.53.166' IDENTIFIED WITH mysql_native_password BY 'password';
```

=>> host: hostname của client


Grant privileges
```
general syntax: GRANT PRIVILEGE ON database.table TO 'username'@'host';
```

```
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, INDEX, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'sammy'@'localhost' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'sammy'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;
```

Show list user
```
SELECT User, Host, Password FROM mysql.user;
```

Revoke privileges user
```
REVOKE SELECT ON *.* FROM 'sally'@'localhost';
```

dump database
```
mysqldump -h 10.5.71.57 -u quandc -pQWRtaW4xMjNACg== kuma_db > kuma_old.sql
```

restore database
```
mysql –h [hostname] –u [username] –p[password] [database_name] < [dump_file.sql]
```

fix lỗi khi restore database mysql: ERROR 1273 (HY000) at line 25: Unknown collation: 'utf8mb4_0900_ai_ci'
```
Lệnh 1: sed -i 's/utf8mb4_0900_ai_ci/utf8_general_ci/g' backup.sql  
Lệnh 2: sed -i 's/CHARSET=utf8mb4/CHARSET=utf8/g' backup.sql  
```