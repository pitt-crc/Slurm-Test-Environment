ARG ROCKY_TAG
FROM rockylinux:$ROCKY_TAG

ARG SLURM_TAG
ARG PYTHON_TAG
LABEL edu.pitt.crc.slurm-tag=$SLURM_TAG
LABEL edu.pitt.crc.rocky-tag=$ROCKY_TAG
LABEL edu.pitt.crc.python-tag=$PYTHON_TAG

# Install any required system tools
RUN yum install -y epel-release  \
    && yum -y --enablerepo=powertools install \
        $PYTHON_TAG \
        wget \
        bzip2 \
        perl \
        gcc \
        gcc-c++\
        vim-enhanced \
        git \
        make \
        munge \
        munge-devel \
        psmisc \
        mariadb-server \
        mariadb-devel  \
        rpm-build \
        pam-devel \
        readline-devel \
        numactl-libs \
        hdf5-devel \
        freeipmi \
        libibmad \
        rrdtool-devel \
        perl-Switch \
        hwloc-libs \
  && yum clean all \
  && rm -rf /var/cache/yum

# Install mariadb
RUN /usr/bin/mysql_install_db \
  && chown -R mysql:mysql /var/lib/mysql \
  && chown -R mysql:mysql /var/log/mariadb/

# Install Slurm
COPY slurm_config/$SLURM_TAG/rpms.tar.gz rpms.tar.gz
RUN tar -xf rpms.tar.gz rpms  \
    && rpm --install rpms/*.rpm  \
    && rm -rf rpms  \
    && rm rpms.tar.gz

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Add config file required for using Slurm
COPY --chown=slurm slurm_config/$SLURM_TAG/slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm --chmod=600 slurm_config/$SLURM_TAG/slurmdbd.conf /etc/slurm/slurmdbd.conf

# The entrypoint script starts the DB and defines necessary DB constructs
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]