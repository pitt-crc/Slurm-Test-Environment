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

echo "Creating JWT key..."
mkdir -p /var/slurmstate
chown slurm /var/slurmstate
/bin/dd if=/dev/random of=/var/slurmstate/jwt_hs256.key bs=32 count=1
chown slurm:slurm /var/slurmstate/jwt_hs256.key
chmod 0600 /var/slurmstate/jwt_hs256.key

echo "Starting slurmdbd..."
/usr/sbin/slurmdbd
sleep 3 # Wait for slurmdbd to start up

echo "Starting slurmctld..."
/usr/sbin/slurmctld -c

# Wait for slurmctld to start up
timeout=0
while [ $timeout -lt 100 ];
do
  echo "  Pinging slurmctld...";
  if scontrol ping | grep -q 'UP'; then
    echo "slurmctld is up";
    break;
  fi
  sleep 5;
  ((timeout=timeout+5));
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
