#!/bin/bash

dstrader/daily_run.sh &

#socat -d -d -d  TCP-LISTEN:${SOCAT_LISTEN_PORT},fork,forever,reuseaddr,keepalive,keepidle=10,keepintvl=10,keepcnt=2 TCP:${SOCAT_DEST_ADDR}:${SOCAT_DEST_PORT} &

/etc/init.d/xvfb start
sleep 1

export DISPLAY=:0
export LOG_PATH=~/logs
/home/docker/IBController/scripts/displaybannerandlaunch.sh
exit_value=$?

/etc/init.d/xvfb stop
exit $exit_value
