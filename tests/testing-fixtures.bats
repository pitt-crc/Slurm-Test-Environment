#!/usr/bin/env bats

# Test the establishment of slurm test fixtures (accounts, partitions, etc.)


@test "development cluster exists" {
  run "sacctmgr show clusters format=Cluster --noheader --parsable2"
  [ "$output" -eq "development" ]
}

@test "multiple partitions available" {
  # Check each cluster name exists in the partition configuration list
  run "scontrol show partition | grep PartitionName"
  [ "$output" -eq *"PartitionName=partition1"* ]
  [ "$output" -eq *"PartitionName=partition2"* ]
}

@test "dummy accounts exist" {
    # Output from this command is blank if account does not exist
    run "sacctmgr -n show assoc account=account1"
    [ "$output" -eq *"account1" ]

    run "sacctmgr -n show assoc account=account2"
    [ "$output" -eq *"account2" ]
}