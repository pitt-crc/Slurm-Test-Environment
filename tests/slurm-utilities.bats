#!/usr/bin/env bats

# Test slurm commandline utilities are installed and slurm system
# services are running in the background.

@test "scontrol should be installed" {
  run scontrol -V
  [ "$status" -eq 0 ]
}

@test "sacctmgr should be installed" {
  run sacctmgr -V
  [ "$status" -eq 0 ]
}

@test "slurmctld should be installed" {
  run slurmctld -V
  [ "$status" -eq 0 ]
}

@test "slurmdbd should be installed" {
  run slurmdbd -V
  [ "$status" -eq 0 ]
}

@test "slurmctld should be running" {
  run scontrol ping
  [ "$status" -eq 0 ]
  [[ "$output" = "Slurmctld(primary) at "*" is UP" ]]
}
