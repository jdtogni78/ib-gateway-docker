#!/bin/bash

wait_tws=15
echo "[DAILY RUN] Wait ${wait_tws} sec"
sleep ${wait_tws}

cd /home/docker/dstrader/runtime

for portfolio in portfolios/portfolio*.json; do
  [[ -e "${portfolio}" ]] || break
  echo "[DAILY RUN] Launching DSTrader for ${portfolio}..."
  java -Dlog4j.configurationFile=log4j2.xml -jar DSTrader.jar "${portfolio}" "${RUNTIME}"
  sleep 60
done

# TODO Maybe a better way to kill it
for p in $(ps -ef | grep ibgateway | awk '{print $2}'); do
  kill $p;
done