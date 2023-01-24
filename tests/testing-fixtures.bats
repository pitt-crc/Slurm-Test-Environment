#!/usr/bin/env bats

# Test the establishment of slurm test fixtures (accounts, partitions, etc.)


@test "development cluster should exists" {
  run sacctmgr show clusters format=Cluster --noheader --parsable2
  [ "$output" = "development" ]
}

@test "multiple partitions should be available" {
  # Check each cluster name exists in the partition configuration list
  run scontrol show partition
  [ "$output" = *"PartitionName=partition1"* ]
  [ "$output" = *"PartitionName=partition2"* ]
}

@test "dummy accounts should exist" {
    # Output from this command is blank if account does not exist
    run sacctmgr -n show assoc account=account1
    [ "$output" = *"account1"* ]

    run sacctmgr -n show assoc account=account2
    [ "$output" = *"account2"* ]
}