# This file is designed to be configured from the commandline
# Specify the following args to use different Slurm and RHEL versions
ARG RHEL_TAG
FROM redhat/$RHEL_TAG

ARG SLURM_TAG
LABEL edu.pitt.crc.slurm-version=$SLURM_TAG
LABEL edu.pitt.crc.rhel-version=$RHEL_TAG

# Install any system tools required to build and to install Slurm
RUN yum -y install git gcc make python3 python3-pip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Define common aliases for python tools
RUN echo -e '#!/bin/bash\npip3' > /usr/bin/pip  \
    && chmod +x /usr/bin/pip \
    && echo -e '#!/bin/bash\npython3' > /usr/bin/python  \
    && chmod +x /usr/bin/python

# Fetch the Slurm source code
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && cd slurm \
    && git checkout tags/$SLURM_TAG

# Build and install Slurm
RUN pushd slurm \
    && ./configure --enable-debug --enable-front-end \
    && make install \
    && popd \
    && rm -rf slurm
