FROM rockylinux:9 as slurmbuild

ARG SLURM_VERSION

# Install any required system tools
RUN dnf install -y epel-release \
  && dnf config-manager --set-enabled crb \
  && dnf install -y \
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
      autoconf \
      automake \
      git \
      rpm-build \
      wget \
      python3 \
      make \
  && dnf clean all \
  && rm -rf /var/cache/dnf

# Build Slurm RPMs
RUN wget https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 \
    && rpmbuild -ta slurm-$SLURM_VERSION.tar.bz2 --with slurmrestd \
    && rm -rf slurm-$SLURM_VERSION.tar.bz2

FROM rockylinux:9
COPY --from=slurmbuild \
    /root/rpmbuild/RPMS/x86_64/slurm-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmctld-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmd-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmdbd-$SLURM_VERSION*.rpm \
    /root/rpmbuild/RPMS/x86_64/slurm-slurmrestd-$SLURM_VERSION*.rpm \
    /root/

ARG SLURM_VERSION

# Install any required system tools
RUN dnf install -y epel-release  \
  && dnf config-manager --set-enabled crb \
  && dnf install -y \
      # Support multiple Python versions for downstream testing scenarios
      python3.11 \
      python3.11-pip \
      python3.12 \
      python3.12-pip \
      python3.13 \
      python3.13-pip \
      python3.14 \
      python3.14-pip \
      # Required by Slurm
      mariadb-server \
      munge \
      # Required by the Slurm REST API \
      http-parser \
      libjwt \
      libyaml \
      json-c \
      # Required for installing python versions not available via dnf
      bzip2-devel \
      libffi-devel \
      openssl-devel \
      wget \
      gcc \
      # General tools provided for use by downstream services
      bats \
      grep \
      make \
      which \
      zlib-devel \
  && dnf clean all \
  && rm -rf /var/cache/dnf

# Install mariadb
RUN /usr/bin/mysql_install_db \
  && chown -R mysql:mysql /var/lib/mysql \
  && chown -R mysql:mysql /var/log/mariadb

# Install Slurm
RUN dnf localinstall -y \
    /root/slurm-$SLURM_VERSION*.rpm \
    /root/slurm-slurmctld-$SLURM_VERSION*.rpm \
    /root/slurm-slurmd-$SLURM_VERSION*.rpm \
    /root/slurm-slurmdbd-$SLURM_VERSION*.rpm \
    /root/slurm-slurmrestd-$SLURM_VERSION*.rpm \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && rm -rf /root/slurm*.rpm

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Add Slurm config files
COPY --chown=slurm slurm_config/$SLURM_VERSION/slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm --chmod=600 slurm_config/$SLURM_VERSION/slurmdbd.conf /etc/slurm/slurmdbd.conf

# The entrypoint script starts the DB and defines necessary DB constructs
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
