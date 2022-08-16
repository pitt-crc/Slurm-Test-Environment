ARG ROCKY_TAG
FROM rockylinux:$ROCKY_TAG

ARG SLURM_TAG
ARG PYTHON_TAG
LABEL edu.pitt.crc.slurm-tag=$SLURM_TAG
LABEL edu.pitt.crc.rocky-tag=$ROCKY_TAG
LABEL edu.pitt.crc.python-tag=$PYTHON_TAG

# Install any required system tools
RUN yum -y --enablerepo=powertools install \
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
        psmisc \
        mariadb-server \
        mariadb-devel  \
        munge-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install mariadb
RUN /usr/bin/mysql_install_db \
  && chown -R mysql:mysql /var/lib/mysql \
  && chown -R mysql:mysql /var/log/mariadb/

# Install Slurm
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git --branch $SLURM_TAG --depth 1  \
    && pushd slurm \
    && ./configure --enable-front-end --prefix=/usr --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
    && make install \
    && popd \
    && rm -rf slurm

# Slurm requires a dedicated user/group to run
RUN groupadd -r slurm && useradd -r -g slurm slurm

# Add config file required for using Slurm
COPY slurm_config/$SLURM_TAG/slurm.conf /etc/slurm/slurm.conf
COPY slurm_config/$SLURM_TAG/slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY slurm_config/$SLURM_TAG/supervisord.conf /etc/

# Make sure config files have correct permissions/ownership
# Some versions of slurm will not work if this is not set properly
RUN chown -R slurm:slurm /etc/slurm/
RUN chmod -R 600 /etc/slurm/

# The entrypoint script starts the DB and defines necessary DB constructs
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]