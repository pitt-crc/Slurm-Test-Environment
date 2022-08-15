#!/bin/bash

echo "launching sql server"
/usr/bin/mysqld_safe --datadir='/var/lib/mysql' &

echo "creating slurm account database"
mysql -NBe "CREATE DATABASE slurm_acct_db"
mysql -NBe "CREATE USER 'slurm'@'localhost'"
mysql -NBe "SET PASSWORD for 'slurm'@'localhost' = password('password')"
mysql -NBe "GRANT USAGE ON *.* to 'slurm'@'localhost'"
mysql -NBe "GRANT ALL PRIVILEGES on slurm_acct_db.* to 'slurm'@'localhost'"
mysql -NBe "FLUSH PRIVILEGES"
echo "finished creating database"

exec "$@"
