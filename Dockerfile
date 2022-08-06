ARG RHEL_TAG
FROM redhat/$RHEL_TAG

ARG SLURM_TAG
ARG PYTHON_TAG
LABEL edu.pitt.crc.slurm-version=$SLURM_TAG
LABEL edu.pitt.crc.rhel-version=$RHEL_TAG
LABEL edu.pitt.crc.python-version=$PYTHON_TAG

# Install any required system tools
RUN yum -y install git gcc make $PYTHON_TAG \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install slurm
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --enable-front-end \
    && make -j ${nproc} \
    && make install \
    && popd \
    && rm -rf slurm
