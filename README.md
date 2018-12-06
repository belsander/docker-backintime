# docker-backintime
[![Build status](https://img.shields.io/docker/build/intelliops/backintime.svg)](https://hub.docker.com/r/intelliops/backintime) [![Build status](https://img.shields.io/travis/belsander/docker-backintime/master.svg)](https://travis-ci.org/belsander/docker-backintime)

Docker container to perform backups using backintime (oriented towards SSH backup mode)

# Supported tags

* `latest` [Dockerfile](https://raw.githubusercontent.com/belsander/docker-backintime/master/Dockerfile)
* `wake-on-lan` [Dockerfile](https://raw.githubusercontent.com/belsander/docker-backintime/wake-on-lan/Dockerfile)

## latest
Latest version of backintime (installed from source).

## wake-on-lan
Same as `latest`, but with the additional feature of powering on the backup
target with WOL and shutting it down again after the backup.

# Usage

## Install
```sh
docker pull intelliops/backintime:latest
```

## Running
```sh
docker run -ti --name backintime \
  -v /home/<USER>/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
  -v /home:/host/home:ro \
  -v /etc:/host/etc:ro \
  -v /root:/host/root:ro \
  -v /usr:/host/usr:ro \
  --net=host \
  --privileged \
  intelliops/backintime:latest
```
```sh
docker run -ti --name backintime \
  -e MAC=aa:bb:cc:00:11:22 \
  -e INTF=eth0 \
  -v /home/<USER>/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
  -v /home:/host/home:ro \
  -v /etc:/host/etc:ro \
  -v /root:/host/root:ro \
  -v /usr:/host/usr:ro \
  --net=host \
  --privileged \
  intelliops/backintime:wake-on-lan
```

TODO: remove privileged flag and specify only needed capabilities:
```
  --cap-add=NET_ADMIN \
  --cap-add=NET_BROADCAST \
  --cap-add=NET_RAW \
  --cap-add=SYS_RESOURCE \
  --cap-add=SYS_ADMIN --device /dev/fuse
```

The backup process will start immediately after starting the container.

## Volumes

| Path | Description |
|--------|--------|
| /root/.ssh/id_rsa | SSH key to login to the backup target |
| /etc/backintime/config | Configuration of backintime |
| /host/<FOLDER_TO_BACKUP> | Directories that need to be included in the backup |

## Configuration

### Environmental variables
Only relevant for `wake-on-lan` version of the Docker image.

| Environmental variable | Description |
|--------|--------|
| MAC | The MAC address of the backup target that will be awakened by WOL |
| INTF | The network interface of the host performing the backup, where the backup target can be found on |

### Custom configuration file
To run the backup, you will have to mount the backintime configuration file into
the Docker container. An example can be found back in `backintime.example`.

# Reference
https://github.com/bit-team/backintime
