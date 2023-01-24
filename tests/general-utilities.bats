#!/usr/bin/env bats

# Test the establishment of general utilities (python, make, etc.).

@test "which is installed" {
  run "which"
  [ "$status" -eq 0 ]
}

@test "grep is installed" {
  run "grep --version"
  [ "$status" -eq 0 ]
}

@test "make is installed" {
  run "make --version"
  [ "$status" -eq 0 ]
}

@test "python tools are installed (system default)" {
  run "python --version"
  [ "$output" -eq "Python 3.9"* ]

  run "pip --version"
  [ "$output" -eq "pip 21.3"* ]

  run "coverage --version"
  [ "$output" -eq "Coverage.py, version 6.4"* ]
}

@test "python tools are installed (python 3.9)" {
  run "python3.9 --version"
  [ "$output" -eq "Python 3.9"* ]

  run "pip3.9 --version"
  [ "$output" -eq "pip 21.3"* ]

  run "coverage-3.9 --version"
  [ "$output" -eq "Coverage.py, version 6.4"* ]
}

@test "python tools are installed (python 3.8)" {
  run "python3.8 --version"
  [ "$output" -eq "Python 3.8"* ]

  run "pip3.8 --version"
  [ "$output" -eq "pip 21.3"* ]

  run "coverage-3.8 --version"
  [ "$output" -eq "Coverage.py, version 6.4"* ]
}
