FROM rockylinux:8 as slurmbuild

ARG SLURM_VERSION

# Install any required system tools
RUN yum install -y epel-release  \
  && yum install -y --enablerepo=powertools \
      # Required for slurm
      #rocm-device-libs \
      hwloc-devel \
      hdf5-devel \
      man2html \
      libibumad \
      freeipmi-devel \
      lua-devel \
      munge-devel \
      mariadb-devel \
      numactl-devel \
      pam-devel \
      pmix-devel \
      readline-devel \
      http-parser-devel \
      json-c-devel \
      libyaml-devel \
      libjwt-devel \
      rrdtool-devel \
      perl-ExtUtils-MakeMaker \
      libbpf-devel \
      dbus-devel \
      git \
      rpm-build \
      wget \
      python3 \
      make \
  && yum clean all \
  && rm -rf /var/cache/yum

RUN wget https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 \
    && rpmbuild -ta slurm-$SLURM_VERSION.tar.bz2 --with slurmrestd \
    && rm -rf slurm-$SLURM_VERSION.tar.bz2

FROM rockylinux:8
COPY --from=slurmbuild \
    /root/rpmbuild/RPMS/x86_64/slurm-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmctld-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmd-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmdbd-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmrestd-$SLURM_VERSION*.rpm \
    /root/

ARG SLURM_VERSION
LABEL edu.pitt.crc.slurm-tag=$SLURM_VERSION

# Install any required system tools
RUN yum install -y epel-release  \
  && yum install -y --enablerepo=powertools \
      # Support multiple Python versions for downstream testing scenarios
      python38 \
      python39 \
      python3.11 \
      mariadb-server \
      munge \
      # Required by the Slurm REST API \
      http-parser \
      libjwt \
      libyaml \
      json-c \
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
      gcc \
  && yum clean all \
  && rm -rf /var/cache/yum

RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz \
    && tar -xzf Python-3.10.0.tgz \
    && cd Python-3.10.0 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && cd / && rm -rf Python-3.10.0.tgz \
    && rm -rf Python-3.10.0

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
RUN yum localinstall --enablerepo=powertools -y \
    /root/slurm-$SLURM_VERSION*.rpm \
    /root/slurm-slurmctld-$SLURM_VERSION*.rpm \
    /root/slurm-slurmd-$SLURM_VERSION*.rpm \
    /root/slurm-slurmdbd-$SLURM_VERSION*.rpm \
    /root/slurm-slurmrestd-$SLURM_VERSION*.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /root/slurm*.rpm

RUN yum remove -y \
    bzip2-devel \
    libffi-devel \
    openssl-devel \
    wget \
    gcc \
    && yum clean all \
    && rm -rf /var/cache/yum

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Add config file required for using Slurm
COPY --chown=slurm slurm_config/$SLURM_VERSION/slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm --chmod=600 slurm_config/$SLURM_VERSION/slurmdbd.conf /etc/slurm/slurmdbd.conf

# The entrypoint script starts the DB and defines necessary DB constructs
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
