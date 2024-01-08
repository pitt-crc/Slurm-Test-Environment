#!/usr/bin/env bats

# Test slurm commandline utilities are installed and slurm system
# services are running in the background.

@test "salloc should be installed" {
  run salloc -V
  [ "$status" -eq 0 ]
}

@test "sbatch should be installed" {
  run sbatch -V
  [ "$status" -eq 0 ]
}

@test "sacct should be installed" {
  run sacct -V
  [ "$status" -eq 0 ]
}

@test "sacctmgr should be installed" {
  run sacctmgr -V
  [ "$status" -eq 0 ]
}

@test "sbcast should be installed" {
  run sbcast -V
  [ "$status" -eq 0 ]
}

@test "scancel should be installed" {
  run scancel -V
  [ "$status" -eq 0 ]
}

@test "squeue should be installed" {
  run squeue -V
  [ "$status" -eq 0 ]
}

@test "sinfo should be installed" {
  run sinfo -V
  [ "$status" -eq 0 ]
}

@test "scontrol should be installed" {
  run scontrol -V
  [ "$status" -eq 0 ]
}

# The following tests check Slurm daemons

@test "slurmd should be installed" {
  run slurmd -V
  [ "$status" -eq 0 ]
}

@test "slurmdbd should be installed" {
  run slurmdbd -V
  [ "$status" -eq 0 ]
}

@test "slurmrestd should be installed" {
  run slurmrestd -V
  [ "$status" -eq 0 ]
}

@test "slurmctld should be running" {
  run scontrol ping
  [ "$status" -eq 0 ]
  [[ "$output" = "Slurmctld(primary) at "*" is UP" ]]
}
