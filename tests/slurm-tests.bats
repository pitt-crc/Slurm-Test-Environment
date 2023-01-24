#!/usr/bin/env bats

@test "test sacctmgr is installed" {
    docker run --rm test-image sacctmgr -V
}

@test "test slurmctld is installed" {
    docker run --rm test-image slurmctld -V
}

@test "test slurmdbd is installed" {
    docker run --rm test-image slurmdbd -V
}