# This file is designed to be configured from the commandline
# Specify the following args to use different Slurm and RHEL versions
ARG SLURM_TAG
ARG RHEL_TAG

RUN test -n "$SLURM_TAG" || (echo "SLURM_TAG variable was not set" && false)
RUN test -n "$RHEL_TAG" || (echo "RHEL_TAG  not set" && false)

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
    && git checkout tags/$SLURM_TAG

# Build and install Slurm
RUN pushd slurm \
    && alias python="python3" \
    && ./configure --enable-debug --enable-front-end \
    && make install \
    && popd \
    && rm -rf slurm
