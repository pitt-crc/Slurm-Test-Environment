ARG ROCKY_TAG
FROM rockylinux:$ROCKY_TAG

ARG SLURM_TAG
ARG PYTHON_TAG
LABEL edu.pitt.crc.slurm-tag=$SLURM_TAG
LABEL edu.pitt.crc.rhel-tag=$ROCKY_TAG
LABEL edu.pitt.crc.python-tag=$PYTHON_TAG

# Install any required system tools
RUN yum -y install git gcc make $PYTHON_TAG mariadb-server \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Install Slurm
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --enable-front-end --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    # && install -D -m644 etc/slurm.epilog.clean /etc/slurm/slurm.epilog.clean \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm

# Add config file required for using Slurm
COPY slurm_config/slurm.conf /etc/slurm/slurm.conf
COPY slurm_config/slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY slurm_config/supervisord.conf /etc/

# This is a check to make sure everything installed correctly
RUN sacctmgr -v