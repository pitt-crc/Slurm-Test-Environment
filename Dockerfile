ARG ROCKY_VERSION
FROM rockylinux:$ROCKY_VERSION

ARG SLURM_VERSION
ARG PYTHON_VERSION
LABEL edu.pitt.crc.slurm-version=$SLURM_VERSION
LABEL edu.pitt.crc.rocky-version=$ROCKY_VERSION
LABEL edu.pitt.crc.python-version=$PYTHON_VERSION

# Install any required system tools
RUN yum -y --enablerepo=powertools install \
    python$PYTHON_VERSION \
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
  && yum clean all \
  && rm -rf /var/cache/yum

# Install mariadb
RUN /usr/bin/mysql_install_db \
  && chown -R mysql:mysql /var/lib/mysql \
  && chown -R mysql:mysql /var/log/mariadb/

# Install Slurm
RUN wget https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 \
  && rpmbuild -ta slurm*.tar.bz2 \
  && rpm --install

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Add config file required for using Slurm
COPY --chown=slurm slurm_config/$SLURM_VERSION/slurm.conf /etc/slurm/slurm.conf
COPY --chown=slurm --chmod=600 slurm_config/$SLURM_VERSION/slurmdbd.conf /etc/slurm/slurmdbd.conf

# The entrypoint script starts the DB and defines necessary DB constructs
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]