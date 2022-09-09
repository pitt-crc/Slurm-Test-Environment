FROM rockylinux:8

ARG SLURM_TAG
LABEL edu.pitt.crc.slurm-tag=$SLURM_TAG

# Install any required system tools
RUN yum install -y epel-release  \
  && yum -y --enablerepo=powertools install \
      python39 \
      # Required for slurm \
      munge \
      munge-devel \
      mariadb-server \
      mariadb-devel  \
      numactl-libs \
      hdf5-devel \
      freeipmi \
      libibmad \
      rrdtool-devel \
      perl-Switch \
      hwloc-libs \
      # Added for integration with IDEs \
      which \
  && yum clean all \
  && rm -rf /var/cache/yum

# Make python tools accessable without the trailing 3
RUN ln /usr/bin/python3 /usr/bin/python && ln /usr/bin/pip3 /usr/bin/pip

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