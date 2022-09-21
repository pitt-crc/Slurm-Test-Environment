# Slurm Test Environments

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/86b83c73f89642dfad48f3a9ec1f0b66)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=pitt-crc/Slurm-Test-Environment&amp;utm_campaign=Badge_Grade)
[![Deploy Docker Images](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/pitt-crc/Slurm-Test-Environment/actions/workflows/docker-publish.yml)

Dockerized environments for testing software against a variety of [Slurm](https://slurm.schedmd.com/overview.html) versions. 

## Using Images in GitHub Actions

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

See the [packages](https://github.com/orgs/pitt-crc/packages?repo_name=Slurm-Test-Environment) section
of this repository for a full list of available container names.

## Building an Image Locally

The Dockerfile is designed to be reusable for Slurm versions.
The slurm version needs to be specified when building an image.
The following example builds an image using Slurm version 20.02.5.1:

```bash
docker build --build-arg SLURM_TAG=slurm-20-02-5-1
```

To see a list of valid Slurm tags, see the [Slurm GitHub release tags](https://github.com/SchedMD/slurm/tags).

## Testing Fixtures

The test environment comes partially configured with running services and mock data. 

### Running services

The following services are automatically launched when spinning up a new container:
- `munge`
- `slurmdbd`
- `slurmctld`

### Slurm Configuration

Slurm is configured with a single mock cluster called ``development``. The following Slurm accounts on the cluster:

| Account Name | Slurm Description | Slurm Organization |
|--------------|-------------------|--------------------|
| account1     | account1_desc     | account1_org       |
| account2     | account2_desc     | account2_org       |

## Creating a New Image

Updating the `latest` branch of this repository will automatically build and 
deploy new image version.
To add a new build with different package versions, make the following changes:

1. Check the Slurm version you want to build against are available from the [upstream source](https://slurm.schedmd.com/overview.html).
2. Add the necessary Slurm rms and config files to the `slurm_config` directory. 
   The name of the subdirectory should match the corresponding `SLURM_TAG` build argument.
3. Update the build matrix section of the GitHub actions workflow to include the new version.
