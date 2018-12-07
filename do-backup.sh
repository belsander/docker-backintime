#!/bin/bash

IP=$(sed -n 's/^profile[0-9]\+\.snapshots\.ssh\.host=\(.*\)$/\1/p' /etc/backintime/config)
USER=$(sed -n 's/^profile[0-9]\+\.snapshots\.ssh\.user=\(.*\)$/\1/p' /etc/backintime/config)
KEY=/root/.ssh/id_rsa
BACKINTIME_ARGS='--debug'

log() {
  echo "$(date) - $1"
}

send_wol() {
  etherwake -i $INTF $MAC
}

# Main
{
  if [ -z $IP ]
  then
    echo "No IP value could be extracted from /etc/backintime/config"
    exit 2
  fi
  if [ -z $USER ]
  then
    echo "No user value could be extracted from /etc/backintime/config"
    exit 2
  fi
  if [ -z $MAC ]
  then
    echo "No MAC environmental variable is available, please set it!"
    exit 3
  fi
  if [ -z $INTF ]
  then
    echo "No INTF environmental variable is available, please set it!"
    exit 3
  fi

  ssh_result_code=1
  attempts=1

  # Assuming that the backup target is always powered off
  while [ $ssh_result_code -ne 0 ] && [ $attempts -lt 10 ]
  do
    log "Attempt ${attempts}: sending Wake-On-LAN"
    send_wol

    log "Attempt ${attempts}: Wake-On-LAN send, waiting for 5 seconds"
    sleep 5

    log "Attempt ${attempts}: checking if SSH connection can be made"
    ssh_result=$(ssh \
      -i $KEY \
      -o "UserKnownHostsFile=/dev/null" \
      -o "StrictHostKeyChecking=no" \
      -o "ServerAliveInterval=60" \
      -o "ServerAliveCountMax=3" \
      -o "ConnectTimeout=5" \
      -o "BatchMode=yes" $USER@$IP exit)
    ssh_result_code=$?

    log "Attempt ${attempts}: SSH check result ($ssh_result_code): " \
      "${ssh_result}"

    attempts=$((attempts+1))
  done

  if [ $ssh_result_code -eq 0 ]
  then
    log "Wake-On-LAN successfull, SSH connection has been made"

    log "Adding target to SSH known_hosts"
    ssh-keyscan -H $IP >> /$(whoami)/.ssh/known_hosts

    log "Checking configuration of backintime"
    backintime check-config --no-crontab $BACKINTIME_ARGS

    log "Starting actual backup with backintime"
    # Run backup (needs to be configured in /etc/backintime/config)
    backintime backup $BACKINTIME_ARGS
    
    log "Backup is done, shutting down backup target"
    # poweroff needs super user permissions, so configure in sudoers
    ssh $USER@$IP -i $KEY sudo poweroff
    
    log "All done, backup target has been shut down"
  else
    log "Failed to SSH login, so assuming Wake-On-LAN failed, cannot backup"
  fi

} || {
  echo "Failed to wake up device via Wake-On-LAN to connect via SSH and " \
    "perform backup"
}
