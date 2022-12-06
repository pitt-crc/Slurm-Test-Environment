# Slurm Test Environments

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/86b83c73f89642dfad48f3a9ec1f0b66)](https://app.codacy.com/gh/pitt-crc/Slurm-Test-Environment/dashboard)
[![Docker Images](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/Docker.yml/badge.svg)](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/Docker.yml)

Dockerized environments for testing software against a variety of [Slurm](https://slurm.schedmd.com/overview.html)
versions.
See the [packages](https://github.com/orgs/pitt-crc/packages?repo_name=Slurm-Test-Environment) section of this
repository for a full list of available containers.

## Working with Images

Refer to the sections below for examples on using the Slurm test environments in different situations.

### Building an Image Locally

The Dockerfile is designed to be reusable for different Slurm versions.
The slurm version needs to be specified when building an image.
The following example builds an image using Slurm version 20.02.5.1:

```bash
docker build --build-arg SLURM_TAG=slurm-20-02-5-1 .
```

For a list of valid Slurm tags, see
the [Slurm config directory](https://github.com/pitt-crc/Slurm-Test-Environment/tree/latest/slurm_config) in this
repository.

You will need to enable [Docker Buildkit](https://docs.docker.com/develop/develop-images/build_enhancements/) to build the image.
To do so, set the following environmental variable:

```bash
DOCKER_BUILDKIT=1
```

### Pulling Existing Images

Test environment images are stored on the GitHub container registry and can be referenced locally via the `docker` utility.
For instructions on pulling images from GitHub, see the
[official docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

Specific image versions can be used by specifying the desired docker tag.
Using the sha256 hash as a tag is not recommended.
Instead, use the `latest` tag for the most recent build, or a tag corresponding to a package release (e.g., `v0.1.0`).

### Using Images in GitHub Actions

To run a GitHub actions job from within a container, specify the `container` option and include a setup step:

```yaml
jobs:
  example_job:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/pitt-crc/test-env-slurm-20-11-9-1

    steps:
      - name: Setup environment
        run: /usr/local/bin/entrypoint.sh
```

If you want to run a job several times using different containers
(e.g., to test software against multiple Slurm versions)
use the `strategy` directive:

```yaml
jobs:
  example_job:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        container:
          - test-env-slurm-22-05-2-1
          - test-env-slurm-20-11-9-1
          - test-env-slurm-20-02-5-1

    container:
      image: ghcr.io/pitt-crc/${{ matrix.container }}

    steps:
      - name: Setup environment
        run: /usr/local/bin/entrypoint.sh
```

## Testing Fixtures

The test environment comes partially configured with various tools, running services, and mock data.

### General Utilities

The following commandline tools are explicitly provided in the testing environment.

- ``which`` (Required for compatibility with some IDE docker integrations)
- ``make``

### Python versions

Multiple Python versions are provided in the test environment, each having dedicated installations
of the `pip` and `coverage` utilities. Installed Python versions include:

- 3.8
- 3.9

Utilities are installed at following paths:

| Executable Name             | Installed Path                       |
|-----------------------------|--------------------------------------|
| `python[PYTHON-VERSION]`    | `/usr/bin/python[PYTHON-VERSION]`    |
| `pip[PYTHON-VERSION]`       | `/usr/bin/pip[PYTHON-VERSION]`       |
| `coverage-[PYTHON-VERSION]` | `/usr/bin/coverage-[PYTHON-VERSION]` |

For each Python install, the following utilities versions are guaranteed:

| Package Name | Package Version |
|--------------|-----------------|
| `coverage`   | `6.4`           |
| `setuptools` | `64`            |
| `pip`        | `21.3`          |

### Running services

The following services are automatically launched when spinning up a new container:

- `mariadb`
- `munge`
- `slurmdbd`
- `slurmctld`

### Slurm Configuration

Slurm is configured with a single mock cluster called ``development`` along with the following Slurm accounts:

| Account Name | Slurm Description | Slurm Organization |
|--------------|-------------------|--------------------|
| account1     | account1_desc     | account1_org       |
| account2     | account2_desc     | account2_org       |

## Adding a New Image

Creating a new release from this repository will automatically build and publish new image versions.
To add a new Slurm version to the build process, make the following changes:

1. Add the necessary Slurm rpms and config files to the `slurm_config` directory.
   The name of the subdirectory should match the corresponding `SLURM_TAG` build argument.
2. Update the build matrix section of the GitHub actions workflow to include the new version.

### Building New Slurm RPMs

Slurm RPMs can be built directly from the compressed Slurm distribution.
The generated RPMs need to be recompressed as a directory called `rpms` before being added to the repository.
The compressed archive should be named with the corresponding Slurm version.

```bash
rpmbuild -ta slurm*.tar.bz2
cp -r rpmbuild/RPMS/x86_64 rpms/
tar -czvf slurm-[MAJOR]-[MINOR]-[PATCH]-[BUILD].tar.gz rpms/
```
