#!/bin/bash

IP=$(sed -n 's/^profile[0-9]\+\.snapshots\.ssh\.host=\(.*\)$/\1/p' /etc/backintime/config)
BACKINTIME_ARGS='--debug'

log() {
  echo "$(date) - $1"
}

# Main
{
    if [ ! -z $IP ]
    then
        log "Adding target to SSH known_hosts"
        ssh-keyscan -H $IP >> /$(whoami)/.ssh/known_hosts
    fi

    log "Checking configuration of backintime"
    backintime check-config --no-crontab $BACKINTIME_ARGS

    log "Starting actual backup with backintime"
    # Run backup (needs to be configured in /etc/backintime/config)
    backintime backup $BACKINTIME_ARGS

} || {
  echo "Failed to perform backup"
}
