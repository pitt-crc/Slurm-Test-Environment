#!/usr/bin/env bats

# Test slurm commandline utilities are installed and slurm system
# services are running in the background.

@test "test scontrol is installed" {
  run "scontrol -V"
  [ "$status" -eq 0 ]
}

@test "test sacctmgr is installed" {
  run "sacctmgr -V"
  [ "$status" -eq 0 ]
}

@test "test slurmctld is installed" {
  run "slurmctld -V"
  [ "$status" -eq 0 ]
}

@test "test slurmdbd is installed" {
  run "slurmdbd -V"
  [ "$status" -eq 0 ]
}

@test "test slurmctld is running" {
  run "scontrol ping"
  [ "$status" -eq 0 ]
  [ "$output" == "Slurmctld(primary) at "*" is UP" ]
}
