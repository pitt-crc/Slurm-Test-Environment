FROM redhat/ubi8

ARG SLURM_TAG=slurm-20-02-5-1
LABEL slurm=20-02-5-1

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
