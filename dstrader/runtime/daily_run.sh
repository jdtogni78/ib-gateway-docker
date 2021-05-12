#!/bin/bash

wait_tws=15
echo "[DAILY RUN] Wait ${wait_tws} sec"
sleep ${wait_tws}

cd "$(dirname "$0")"

for portfolio in portfolios/portfolio*.json; do
  [[ -e "${portfolio}" ]] || break
  echo "[DAILY RUN] Launching DSTrader for ${portfolio}..."
  java -jar DSTrader.jar "${portfolio}"
  sleep 60
done

# TODO Maybe a better way to kill it
for p in $(ps -ef | grep ibgateway | awk '{print $2}'); do
  kill $p;
done