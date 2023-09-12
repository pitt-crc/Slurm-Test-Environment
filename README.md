# Slurm Test Environments

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/86b83c73f89642dfad48f3a9ec1f0b66)](https://app.codacy.com/gh/pitt-crc/Slurm-Test-Environment/dashboard)
[![](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/DockerTest.yml/badge.svg)](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/DockerTest.yml)
[![](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/DockerPublish.yml/badge.svg)](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/DockerPublish.yml)

Dockerized environments for testing software against a variety of [Slurm](https://slurm.schedmd.com/overview.html) versions. 

## Working with Images

Refer to the sections below for examples on using the Slurm test environments in different situations.

### Pulling Existing Images

Pre-built images are stored on the GitHub container registry and can be referenced locally via the `docker` utility.
For instructions on pulling images from GitHub, see the [official docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

Specific Slurm versions can be requested using docker tags.
For example, slurm version `aa.bb.c.d` can be pulled using:

```bash
  docker pull ghcr.io/pitt-crc/test-env:aa.bb.c.d
```

A full list of availible versions is availible [here](https://github.com/pitt-crc/Slurm-Test-Environment/pkgs/container/test-env).
The `latest` tag points to the latest availible slurm version.

### Building an Image Locally

You will need to enable [Docker Buildkit](https://docs.docker.com/develop/develop-images/build_enhancements/) to build the image.
To do so, set the following environmental variable:

```bash
DOCKER_BUILDKIT=1
```

The Dockerfile is designed to be reusable for different Slurm versions.
The Slurm version needs to be specified when building an image.
The following example builds an image using Slurm version 20.02.5.1:

```bash
docker build --build-arg SLURM_VERSION=20.02.5.1 .
```

For a list of valid Slurm version tags, see the [SLURM config directory](https://github.com/pitt-crc/Slurm-Test-Environment/tree/latest/slurm_config) in this repository.

Once you have built an image, the test suite can be run from within the docker container:

```bash
docker run -v $(pwd)/tests:/tests -i [IMAGE NAME] bats /tests
```

### Using Images in GitHub Actions

To run a GitHub actions job from within a container, specify the `container` option.
GitHub actions will not automatically launch the container entrypoint.
Instead, you should include a dedicated setup step as follows:

```yaml
jobs:
  example_job:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/pitt-crc/test-env:20.11.9.1

    steps:
      - name: Setup environment
        run: /usr/local/bin/entrypoint.sh
```

If you want to run a job several times using different containers (e.g., to test software against multiple Slurm versions) use the `strategy` directive:

```yaml
jobs:
  example_job:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        slurm_version:
          - 22-05-2-1
          - 20-11-9-1
          - 20-02-5-1

    container:
      image: ghcr.io/pitt-crc/test-env:${{ matrix.slurm_version }}

    steps:
      - name: Setup environment
        run: /usr/local/bin/entrypoint.sh
```

## Testing Fixtures

The test environment comes partially configured with various tools, running services, and mock data.
All images are built using the [Rocky 8](https://hub.docker.com/_/rockylinux) opperating system.

### Slurm Configuration

The installed Slurm instance is configured with the following Slurm partitions:

| Cluster Name | Partition Name |
| ------------ | -------------- |
| development  | partition1     |
| development  | partition2     |

The installed Slurm instance also includes the following accounts:

| Account Name | Slurm Description | Slurm Organization |
| ------------ | ----------------- | ------------------ |
| account1     | account1_desc     | account1_org       |
| account2     | account2_desc     | account2_org       |

### Running services

The following services are automatically launched when spinning up a new container:

- `mariadb`
- `munge`
- `slurmdbd`
- `slurmctld`

### Python versions

Multiple Python versions are provided in the test environment, each having dedicated a dedicated `pip` installation.
Installed Python versions include:

- 3.8
- 3.9

All Python interpreters are installed in the standard location under `/usr/bin/`.

### General Utilities

The following commandline tools are explicitly provided in the testing environment.

- ``which`` (Required for compatibility with some IDE docker integrations)
- ``make``

## Adding a New Image

Creating a new release from this repository will automatically build and publish new image versions.
To add a new Slurm version to the build process, make the following changes:

1. Add the necessary Slurm RPMs and config files to the `slurm_config` directory.
   The name of the subdirectory should match the corresponding `SLURM_VERSION` build argument.
2. Update the strategy matrix in the
   [testing](https://github.com/pitt-crc/Slurm-Test-Environment/blob/latest/.github/workflows/DockerTest.yml)
   and [publication](https://github.com/pitt-crc/Slurm-Test-Environment/blob/latest/.github/workflows/DockerPublish.yml)
   workflows to include the new slurm version.
   Always ensure the `latest` tag points to the correct image.

### Building New SLURM RPMs

Slurm RPMs can be built directly from the compressed Slurm distribution.
The generated RPMs need to be recompressed as a directory called `rpms` before being added to the repository.
The compressed archive should be named with the corresponding Slurm version.

```bash
rpmbuild -ta slurm*.tar.bz2
cp -r rpmbuild/RPMS/x86_64 rpms/
tar -czvf slurm-[MAJOR]-[MINOR]-[PATCH]-[BUILD].tar.gz rpms/
```
