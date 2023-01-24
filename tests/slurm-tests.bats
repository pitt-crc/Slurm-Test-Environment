#!/usr/bin/env bats

@test "test sacctmgr is installed" {
    docker run --rm test-image sacctmgr -V
}

@test "test sacctmgr is installed" {
    docker run --rm test-image slurmctld -V
}

@test "test sacctmgr is installed" {
    docker run --rm test-image slurmdbd -V
}