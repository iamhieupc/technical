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
CREATE USER 'username'@'host' IDENTIFIED WITH mysql_native_password BY 'password';
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