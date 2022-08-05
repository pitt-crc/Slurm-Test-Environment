# This file is designed to be configured from the commandline
# Specify the following args to use different Slurm and RHEL versions
ARG RHEL_TAG
FROM redhat/$RHEL_TAG

ARG SLURM_TAG
LABEL edu.pitt.crc.slurm-version=$SLURM_TAG
LABEL edu.pitt.crc.rhel-version=$RHEL_TAG

# Install any system tools required to build and to install Slurm
RUN yum -y install git gcc make python3 python-pip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Fetch the Slurm source code
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && cd slurm \
    && git checkout tags/$SLURM_TAG

# Build and install Slurm
RUN pushd slurm \
    && alias python="python3" \
    && ./configure --enable-debug --enable-front-end \
    && make install \
    && popd \
    && rm -rf slurm
