#!/bin/bash

function dstrader_encr() {
  FILE=$1
  if [ -f ${FILE} ]; then
    echo Before encrypting ${FILE}
    ls ${FILE}*

    echo Encrypting ${FILE}
    rm -f ${FILE}.encr && \
    gpg -o ${FILE}.encr -e -r jdtogni@gmail.com ${FILE} && \
    rm ${FILE}

    echo After encrypting ${FILE}
    ls ${FILE}*
  fi
}

function dstrader_decr() {
  FILE=$1
  # lets first encript when file is recreated
  dstrader_encr ${FILE}
  # usually we will only decript though

  echo Decrypting ${FILE}
  gpg -o ${FILE} -d ${FILE}.encr

  echo After decrypting ${FILE}
  ls ${FILE}*
}

cd "$(dirname "$0")"  && dstrader_decr mail.properties
cd ../../ib           && dstrader_decr IBController.ini.dtogni
