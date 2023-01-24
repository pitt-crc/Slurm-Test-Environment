#!/usr/bin/env bats

# Test slurm commandline utilities are installed and slurm system
# services are running in the background.

@test "test scontrol is installed" {
  run "docker run --rm test-image scontrol -V"
  [ "$status" -eq 0 ]
}

@test "test sacctmgr is installed" {
  run "docker run --rm test-image sacctmgr -V"
  [ "$status" -eq 0 ]
}

@test "test slurmctld is installed" {
  run "docker run --rm test-image slurmctld -V"
  [ "$status" -eq 0 ]
}

@test "test slurmdbd is installed" {
  run "docker run --rm test-image slurmdbd -V"
  [ "$status" -eq 0 ]
}

@test "test slurmctld is running" {
  run "docker run --rm test-image scontrol ping"
  [ "$status" -eq 0 ]
  [ "$output" == "Slurmctld(primary) at "*" is UP" ]
}
