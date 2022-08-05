# This file is configurable from the commandline to use
# customizable Slurm and RHEL versions
ARG SLURM_TAG
ARG RHEL_TAG

FROM redhat/$RHEL_TAG

LABEL edu.pitt.crc.slurm-version=$SLURM_TAG
LABEL edu.pitt.crc.rhel-version=$RHEL_TAG

# Install any system tools required to build and to install Slurm
RUN yum -y install git gcc make python3 \
    && yum clean all \
    && rm -rf /var/cache/yum

# Fetch the Slurm source code
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && cd slurm \
    && git checkout tags/slurm_tag

# Build and install Slurm
RUN pushd slurm \
    && alias python="python3" \
    && ./configure --enable-debug --enable-front-end \
    && make install \
    && popd \
    && rm -rf slurm
