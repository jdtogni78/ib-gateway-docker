#!/bin/bash

wait_tws=15
echo "[DAILY RUN] Wait ${wait_tws} sec"
sleep ${wait_tws}

cd /home/docker/dstrader/runtime

TWS_PORT=4002
[[ "$TRADING_MODE" == "live" ]] && TWS_PORT=4001

for portfolio in portfolios/portfolio*.json; do
  [[ -e "${portfolio}" ]] || break
  echo "[DAILY RUN] Launching DSTrader for ${portfolio}..."
  java -Dlog4j.configurationFile=log4j2.xml -jar DSTrader.jar "${portfolio}" "${RUNTIME}" "${TWS_PORT}"
  sleep 15
done

# TODO Maybe a better way to kill it
for p in $(ps -ef | grep ibgateway | awk '{print $2}'); do
  kill $p;
done