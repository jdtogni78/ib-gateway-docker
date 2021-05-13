#!/bin/bash

function dstrader_clear() {
  FILE=$1
  echo Clear ${FILE}
  rm ${FILE}

  echo After clear ${FILE}
  ls ${FILE}*
}

cd "$(dirname "$0")" && dstrader_clear mail.properties
cd ../../ib          && dstrader_clear IBController.ini.dtogni
