#!/usr/bin/env bats

# Test behavior of the dockerfile/container itself.
# These tests are designed to be run outside the docker container

@test "container is restartable" {
  # Create and launch a new container
  docker container create --name rerun_test_container test-image
  docker container start -i rerun_test_container

  # Restart the existing container and cleanup
  docker container start -i rerun_test_container
  docker container rm rerun_test_container
}