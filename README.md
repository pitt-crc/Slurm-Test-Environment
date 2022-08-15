# CRC Test Environments

[![Deploy Docker Images](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/docker-publish.yml)

Dockerized environments for testing software against a variety of 
[Rocky](https://rockylinux.org/), [Slurm](https://slurm.schedmd.com/overview.html), 
and [Python](https://www.python.org/) versions. 

## Using Images in GitHub Actions

To run a GitHub actions job from within a container, specify the `container` option:

```yaml
jobs:
  example_job:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/pitt-crc/test-env-ubi8-slurm-20-11-9-1-python38
```

If you want to run a job several times using different containers 
(e.g., to test software against multiple slurm versions)
use the `strategy` directive:

```yaml
jobs:
  example_job:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        container:
          - test-env-ubi8-slurm-20-11-9-1-python38
          - test-env-ubi8-slurm-20-11-9-1-python39
          - test-env-ubi8-slurm-20-02-5-1-python38
          - test-env-ubi8-slurm-20-02-5-1-python39

    container:
      image: ghcr.io/pitt-crc/${{ matrix.container }}
```

See the [packages](https://github.com/orgs/pitt-crc/packages?repo_name=Slurm-Test-Environment) section
of this repository for a full list of available container names.

## Building an Image Locally

The Dockerfile is designed to be reusable for different Rocky, Python, and Slurm versions.
All of these versions need to be specified when building the image.
Failure to specify the necessary arguments will cause a failed build.

The following example builds an image using Rocky 8 and slurm version 20.02.5.1

```bash
docker build . \
    --build-arg ROCKY_TAG=8.6 \
    --build-arg SLURM_TAG=slurm-20-02-5-1 \
    --build-arg PYTHON_TAG=python39
```

To see a list of valid slurm tags, see the [slurm GitHub release tags](https://github.com/SchedMD/slurm/tags).

To see a list of valid Rocky tags, see the [Rocky DockerHub images](https://hub.docker.com/_/rockylinux).

To see a list of valid Python tags, check the yum package repository

## Deploying an Image

Updating the `main` branch of this repository will automatically build and 
deploy new images a variety of RHEL and Slurm and versions. 
These versions are defined in the GitHub actions workflow file.
