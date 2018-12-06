# docker-backintime
[![Build status](https://img.shields.io/docker/build/intelliops/backintime.svg)](https://hub.docker.com/r/intelliops/backintime) [![Build status](https://img.shields.io/travis/belsander/docker-backintime/master.svg)](https://travis-ci.org/belsander/docker-backintime)

Docker container to perform backups using backintime (oriented towards SSH backup mode)

# Supported tags

* `latest` [Dockerfile](https://raw.githubusercontent.com/belsander/docker-backintime/master/Dockerfile)

## latest
Latest version of backintime (installed from source).

## wake-on-lan
TODO, will be available soon.

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

### Custom configuration file
To run the backup, you will have to mount the backintime configuration file into
the Docker container. An example can be found back in `backintime.example`.

# Reference
https://github.com/bit-team/backintime
