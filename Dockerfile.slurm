FROM ubuntu:20.04 AS builder

LABEL essentialsofparallelcomputing/chapter15 \
      Robey and Zamora

ENV PATH "/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

# Install dependency packages
RUN cp /etc/apt/sources.list /etc/apt/sources.list~ && \
    sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
RUN set -ex \
    && apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -qq build-dep -y munge slurm-wlm \
    && apt-get -qq install git vim man2html liblz4-dev libcurl4-openssl-dev munge \
         python python-setuptools python-dev mariadb-server supervisor netcat wget expect

# make /bin/sh symlink to bash instead of dash:
#RUN echo "dash dash/sh boolean false" | debconf-set-selections
#RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN wget ftp://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz && tar -xzf bash-5.0.tar.gz && \
      cd bash-5.0 && ./configure --enable-net-redirections && \
      make && make install && cd .. && rm -rf bash-5.0 bash-5.0.tar.gz

#RUN rm -f /var/lib/mysql/ibdata1

# Compile, build and install Slurm from Git source
ARG SLURM_TAG=slurm-19-05-4-1
RUN set -ex \
    && git clone https://github.com/SchedMD/slurm.git \
    && cd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --enable-front-end --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && cd .. \
    && rm -rf slurm \
    && groupadd -r slurm  \
    && useradd -r -g slurm slurm \
    && mkdir -p /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && chown slurm:root /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && mkdir -p /var/run/supervisor \
    && mkdir -p /var/run/mariadb \
    && mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R mysql:mysql /var/run/mariadb \
    && chown -R mysql:mysql /var/run/mysqld \
    && mkdir -p /run/munge \
    && chown munge:munge /run/munge \
    && /usr/sbin/create-munge-key

# Copy Slurm configuration files into the container
COPY files/slurm/slurm.conf /etc/slurm/slurm.conf
#COPY files/slurm/gres.conf /etc/slurm/gres.conf
COPY files/slurm/slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY files/supervisord.conf /etc/

# Mark externally mounted volumes
VOLUME ["/var/lib/mysql", "/var/lib/slurmd", "/var/spool/slurmd", "/var/log/slurm"]

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN git clone --recursive https://github.com/EssentialsOfParallelComputing/Chapter15

# Add Tini
ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/bash"]
