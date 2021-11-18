#!/bin/bash

export TRADING_MODE=paper # either paper or live
export RUNTIME=stage

dstrader/daily_run.sh &

#socat -d -d -d  TCP-LISTEN:${SOCAT_LISTEN_PORT},fork,forever,reuseaddr,keepalive,keepidle=10,keepintvl=10,keepcnt=2 TCP:${SOCAT_DEST_ADDR}:${SOCAT_DEST_PORT} &

/etc/init.d/xvfb start
sleep 1

export DISPLAY=host.docker.internal:0
export LOG_PATH=~/logs
export IBC_PATH=/opt/IBController
${IBC_PATH}/scripts/displaybannerandlaunch.sh
exit_value=$?

/etc/init.d/xvfb stop
exit $exit_value
