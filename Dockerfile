FROM rockylinux:8

ARG SLURM_TAG
LABEL edu.pitt.crc.slurm-tag=$SLURM_TAG

RUN asdf

# Install any required system tools
RUN yum install -y epel-release  \
  && yum -y --enablerepo=powertools install \
      # Support multiple Python versions for downstream testing scenarios
      python38 python39 \
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
      # General tools provided explicitly for use by downstream services
      which \
      make \
  && yum clean all \
  && rm -rf /var/cache/yum

# Install coverage utilities, latest version last
RUN pip-3.8 install -U coverage==6.4 setuptools==64 pip==21.3 && \
    pip-3.9 install -U coverage==6.4 setuptools==64 pip==21.3

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