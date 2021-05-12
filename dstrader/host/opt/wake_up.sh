#!/bin/bash

function wake_up {
  h=$1
  m=$2
  date
  /usr/sbin/rtcwake -m mem -t  "$([ $(date +%H%M) -lt ${h}${m} ] && date -d "$h:$m" '+%s' || date -d "tomorrow ${h}:${m}" '+%s')"
}

wake_up $*
