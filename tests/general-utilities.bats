#!/usr/bin/env bats

# Test the installation of general utilities (python, make, etc.).

@test "which should be installed" {
  run which which
  [ "$status" -eq 0 ]
}

@test "make should be installed" {
  run make --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.15)" {
  run python3.15 --version
  [[ "$output" = "Python 3.11"* ]]

  run pip3.15 --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.12)" {
  run python3.12 --version
  [[ "$output" = "Python 3.12"* ]]

  run pip3.12 --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.13)" {
  run python3.13 --version
  [[ "$output" = "Python 3.13"* ]]

  run pip3.13 --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.14)" {
  run python3.14 --version
  [[ "$output" = "Python 3.14"* ]]

  run pip3.14 --version
  [ "$status" -eq 0 ]
}
