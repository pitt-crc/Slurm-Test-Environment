#!/usr/bin/env bats

@test "test container is restartable" {
    docker container create --name rerun_test_container test-image
    docker container start -i rerun_test_container
    docker container start -i rerun_test_container
    docker container rm rerun_test_container
}