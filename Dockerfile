FROM       ubuntu:22.04 as BACKINTIME-BUILDER

ARG        BACKINTIME_VERSION=1.3.3

RUN        apt-get update && \
           apt-get install -q -y \
             debhelper \
             dh-python \
             git \
             build-essential \
             gettext \
             python3-pyfakefs \
             python3 \
             rsync \
             cron \
             openssh-client \
             python3-keyring \
             python3-dbus \
             python3-packaging && \
           rm -rf /var/lib/apt/lists/* /var/tmp/*

WORKDIR    /tmp/

RUN        git clone \
             --depth 1 \
             --branch v${BACKINTIME_VERSION} \
             https://github.com/bit-team/backintime.git

WORKDIR    /tmp/backintime/common

RUN        ./configure && \
           make 

WORKDIR    /tmp/backintime

RUN        ./makedeb.sh

WORKDIR    /tmp

RUN        mv backintime-common_$(cat backintime/VERSION)_all.deb \
             backintime-common.deb

FROM       ubuntu:22.04

LABEL      maintainer="Sander Bel <sander@intelliops.be>"

RUN        apt-get update && \
           apt-get install -q -y \
             python3 \
             rsync \
             cron \
             openssh-client \
             python3-keyring \
             python3-dbus \
             python3-packaging \
             sshfs && \
           rm -rf /var/lib/apt/lists/* /var/tmp/*

WORKDIR    /tmp

COPY       --from=BACKINTIME-BUILDER /tmp/backintime-common.deb .

RUN        dpkg -i backintime-common.deb && \
           rm -f backintime-common.deb

RUN        mkdir .ssh && \
           chmod 700 .ssh

WORKDIR    /root

COPY       do-backup.sh .

ENTRYPOINT ["sh", "-c", "/root/do-backup.sh"]
