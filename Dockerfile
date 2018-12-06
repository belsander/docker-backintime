FROM       ubuntu:16.04 as BACKINTIME-BUILDER
# Using 16.04 for python 3.5

ARG        BACKINTIME_VERSION=1.2.0~alpha0

RUN        apt-get update && \
           apt-get install -q -y \
             git \
             rsync \
             openssh-client \
             sshfs \
             dpkg-dev \
             dh-python \
             debhelper \
             python3 \
             python3-keyring \
             python3-dbus && \
           rm -rf /var/lib/apt/lists/* /var/tmp/*

WORKDIR    /tmp/backintime

RUN        git clone https://github.com/belsander/backintime.git src

WORKDIR    /tmp/backintime/src

RUN        ./makedeb.sh

WORKDIR    /tmp/backintime

RUN        mv backintime-common_${BACKINTIME_VERSION}_all.deb  \
             backintime-common.deb

FROM       ubuntu:16.04

LABEL      maintainer="Sander Bel <sander@intelliops.be>"

RUN        apt-get update && \
           apt-get install -q -y \
             rsync \
             sshfs \
             openssh-client \
             python3 \
             python3-keyring \
             python3-dbus \
             cron && \
           rm -rf /var/lib/apt/lists/* /var/tmp/*

WORKDIR    /root

COPY       --from=BACKINTIME-BUILDER /tmp/backintime/backintime-common.deb .

RUN        dpkg -i backintime-common.deb && \
           rm -f backintime-common.deb

RUN        mkdir .ssh && \
           chmod 700 .ssh

COPY       do-backup.sh .

ENTRYPOINT ["sh", "-c", "do-backup.sh"]
