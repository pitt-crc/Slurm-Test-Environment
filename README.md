# CRC Test Environments

Dockerized environments for software development against RedHat linux and Slurm.

TODO: Add a description here

# Building and Image

The Dockerfile is designed to be reusable for different RHEL and Slurm.
Both of these versions need to be specified when building the image.
Failure to specify the necessary arguments will cause a failed build.

The following example builds an image using RHEL8 and slurm version 20.02.5.1

```bash
docker build --build-arg SLURM_TAG=ubi8 --build-arg RHEL_TAG=slurm-20-02-5-1 .
```

# CI/CD

New images are automatically built and deployed to the GitHub package registry for 
a variety of RHEL and Slurm and versions. 
These versions are defined in the GitHub actions workflow file.

TODO: Add instructions for building a workflow here
