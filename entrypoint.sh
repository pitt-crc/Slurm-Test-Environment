#!/bin/bash
set -eo pipefail

echo "Launching sql server..."
/usr/bin/mysqld_safe --datadir='/var/lib/mysql' &
sleep 3 # Wait for mysql to start up

echo "Creating Slurm account database..."
mysql -NBe "CREATE DATABASE IF NOT EXISTS slurm_acct_db"
mysql -NBe "CREATE USER IF NOT EXISTS 'slurm'@'localhost'"
mysql -NBe "GRANT USAGE ON *.* to 'slurm'@'localhost'"
mysql -NBe "GRANT ALL PRIVILEGES on slurm_acct_db.* to 'slurm'@'localhost'"
mysql -NBe "FLUSH PRIVILEGES"

echo "Create munge key..."
/usr/sbin/create-munge-key -f

echo "Starting munge..."
/usr/sbin/runuser -u munge -- /usr/sbin/munged

echo "Starting slurmdbd..."
/usr/sbin/slurmdbd
sleep 3 # Wait for slurmdbd to start up

echo "Starting slurmctld..."
mkdir -p /var/slurmstate
chown slurm /var/slurmstate
/usr/sbin/slurmctld -c
# Wait for slurmctld to start up
until scontrol ping | grep UP; do sleep 3; done
# Wait for slurmctld to start up
timeout=0
until scontrol ping | grep UP;
do
  echo "  Pinging slurmctld...";
  ((timeout++));
  if [[ $timeout -gt 10 ]]
  then
    break
  fi
  sleep 1;
done

if [ "$(sacctmgr show -np account account1)" ]; then
  echo "Mock accounts already exist"
else
  echo "Creating mock user accounts..."
  sacctmgr -i add account "account1" description="account1_desc" organization="account1_org"
  sacctmgr -i add account "account2" description="account2_desc" organization="account2_org"
fi

echo "Environment is ready"
exec "$@"
