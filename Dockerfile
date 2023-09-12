FROM rockylinux:8

ARG SLURM_VERSION
LABEL edu.pitt.crc.slurm-tag=$SLURM_VERSION

# Install any required system tools
RUN yum install -y epel-release  \
  && yum install -y --enablerepo=powertools \
      # Support multiple Python versions for downstream testing scenarios
      python38 \
      python39 \
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
      # Required for installing python version availible via yum
      bzip2-devel \
      libffi-devel \
      openssl-devel \
      # General tools provided explicitly for use by downstream services
      bats \
      grep \
      make \
      which \
  && yum clean all \
  && rm -rf /var/cache/yum

# Install more recent pip versions
RUN pip-3.8 install pip==21.3 && pip-3.8 cache purge  && \
    pip-3.9 install pip==21.3 && pip-3.9 cache purge

# Install mariadb
RUN /usr/bin/mysql_install_db \
  && chown -R mysql:mysql /var/lib/mysql \
  && chown -R mysql:mysql /var/log/mariadb/

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
