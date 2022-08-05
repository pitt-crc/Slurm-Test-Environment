# CRC Test Environments

Dockerized environments for software development against RedHat linux and Slurm.

TODO: Add a description here

## Using an Image

TODO: Add instructions for building a workflow here

## Building an Image

The Dockerfile is designed to be reusable for different RHEL and Slurm versions.
Both of these versions need to be specified when building the image.
Failure to specify the necessary arguments will cause a failed build.

The following example builds an image using RHEL8 and slurm version 20.02.5.1

```bash
docker build --build-arg RHEL_TAG=ubi8 --build-arg SLURM_TAG=slurm-20-02-5-1 .
```

To see a list of valid slurm tags, see the [slurm GitHub release tags](https://github.com/SchedMD/slurm/tags).

To see a list of valid RHEL tags, see the [RHEL DockerHub images](https://hub.docker.com/u/redhat).

# Deploying an Image

Updating the `main` branch of this repository will automatically build and 
deploy new images a variety of RHEL and Slurm and versions. 
These versions are defined in the GitHub actions workflow file.
