Install: https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart

Muốn quy cập vào psql từ bên ngoài thì phải sửa file: /etc/postgresql/16/main/pg_hba.conf
    host    all all 0.0.0.0/0   md5

Các command trong Postgresql
- - Connect to a Database: **psql -U hieupc -h localhost -d hieupc_db --password**
- Check Postgres Version: “**SELECT VERSION();**”.
- List All Databases: “**\l**”.
- Access or Switch a Database: “**\c db_name**”.
- List All Tables: “**\dt**”.
- Describe All Tables: “**\d**”.
- Describe a Specific Table: “**\d tab_name**”.
- List All Schemas: “**\dn**”.
- List All Views: “**\dv**”.
- List All Functions: “**\df**”.
- List All Users: “**\du**”.
- Show Commands History: “**\s**”
- Save Query’s Results to a Specific File: “**\o file_name**
- Run psql Commands/queries From a Particular File: **\e_i filname**
- Execute Previous Command: **\g**
- Show Query Execution Time: “**\timing**”.
- Get Output in HTML Format: “**\H**”.
- Align Columns Output: “**\a**”.
- Get Help: “**\h**”.
- Get All psql Commands: “**\?**”.
- Clear Screen: “**\! cls**”.
- Quit psql: “**\q**”.
- create database: `CREATE DATABASE lusiadas;`
- grant permission to user: grant all priveleges database “persoons” to hieupc;
- dump: pg_dump dbname > outfile
- restore: psql dbname < infile
- create table in database:
    CREATE TABLE account_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    grant_date TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (role_id)
    REFERENCES roles (role_id),
    FOREIGN KEY (user_id)
    REFERENCES accounts (user_id)
    );