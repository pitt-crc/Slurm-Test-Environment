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

@test "python tools should be installed (python 3.8)" {
  run python3.8 --version
  [[ "$output" = "Python 3.8"* ]]

  run pip3.8 --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.9)" {
  run python3.9 --version
  [[ "$output" = "Python 3.9"* ]]

  run pip3.9 --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.10)" {
  run python3.10 --version
  [[ "$output" = "Python 3.10"* ]]

  run pip3.10 --version
  [ "$status" -eq 0 ]
}

@test "python tools should be installed (python 3.11)" {
  run python3.11 --version
  [[ "$output" = "Python 3.11"* ]]

  run pip3.11 --version
  [ "$status" -eq 0 ]
}
