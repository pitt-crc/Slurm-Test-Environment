#!/bin/bash
set -eo pipefail

echo "Launching sql server..."
/usr/bin/mysqld_safe --datadir='/var/lib/mysql' &
sleep 3 # Wait for mysql to start up

echo "Creating Slurm account database..."
mysql -NBe "CREATE DATABASE slurm_acct_db"
mysql -NBe "CREATE USER 'slurm'@'localhost'"
mysql -NBe "GRANT USAGE ON *.* to 'slurm'@'localhost'"
mysql -NBe "GRANT ALL PRIVILEGES on slurm_acct_db.* to 'slurm'@'localhost'"
mysql -NBe "FLUSH PRIVILEGES"

echo "Create munge key..."
/usr/sbin/create-munge-key

echo "Starting munge..."
/usr/sbin/runuser -u munge -- /usr/sbin/munged

echo "Starting slurmdbd..."
/usr/sbin/slurmdbd
sleep 3 # Wait for slurmdbd to start up

echo "Starting slurmctld..."
mkdir /var/slurmstate
chown slurm /var/slurmstate
/usr/sbin/slurmctld -c
sleep 3 # Wait for slurmctld to start up

echo "Creating mock user accounts..."
sacctmgr -i add account "account1" description="account1_desc" organization="account1_org"
sacctmgr -i add account "account2" description="account2_desc" organization="account2_org"

echo "Environment is ready"
exec "$@"
