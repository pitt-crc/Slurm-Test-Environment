FROM rockylinux:8

ARG SLURM_VERSION
LABEL edu.pitt.crc.slurm-tag=$SLURM_VERSION

# Install any required system tools
RUN yum install -y epel-release  \
  && yum install -y --enablerepo=powertools \
      # Support multiple Python versions for downstream testing scenarios
      python38 \
      python39 \
      python3.11 \
      # Required for slurm
      freeipmi \
      hdf5-devel \
      hwloc-libs \
      libibmad \
      mariadb-devel  \
      mariadb-server \
      munge \
      munge-devel \
      numactl-libs \
      perl-Switch \
      rrdtool-devel \
      # Required for installing python versions not availible via yum
      bzip2-devel \
      libffi-devel \
      openssl-devel \
      # General tools provided for use by downstream services
      bats \
      grep \
      make \
      which \
      wget \
  && yum clean all \
  && rm -rf /var/cache/yum

RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz \
    && tar -xzf Python-3.10.0.tgz \
    && cd Python-3.10.0 \
    && ./configure --enable-optimizations \
    && make altinstall

# Install more recent pip versions
RUN pip3.8 install --upgrade pip && pip3.8 cache purge && \
    pip3.9 install --upgrade pip && pip3.9 cache purge && \
    pip3.10 install --upgrade pip && pip3.10 cache purge && \
    pip3.11 install --upgrade pip && pip3.11 cache purge

# Install mariadb
RUN /usr/bin/mysql_install_db \
  && chown -R mysql:mysql /var/lib/mysql \
  && chown -R mysql:mysql /var/log/mariadb

# Install Slurm
COPY slurm_config/$SLURM_VERSION/rpms.tar.gz rpms.tar.gz
RUN tar -xf rpms.tar.gz rpms  \
    && rpm --install rpms/*.rpm  \
    && rm -rf rpms  \
    && rm rpms.tar.gz

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Add config file required for using Slurm
COPY --chown=slurm slurm_config/$SLURM_VERSION/slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm --chmod=600 slurm_config/$SLURM_VERSION/slurmdbd.conf /etc/slurm/slurmdbd.conf

# The entrypoint script starts the DB and defines necessary DB constructs
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
