#!/bin/bash

function dstrader_encr() {
  FILE=$1
  if [ -f ${FILE} ]; then
    echo "* Before encrypting ${FILE}"
    ls ${FILE}*

    echo "Encrypting ${FILE}"
    rm -f ${FILE}.encr && \
    gpg -o ${FILE}.encr -e -r jdtogni@gmail.com ${FILE} && \
    shred -un 3 ${FILE}

    echo "* After encrypting ${FILE}"
    ls ${FILE}*

    echo .
  fi
}

function dstrader_decr() {
  FILE=$1
  # lets first encript when file is recreated
  dstrader_encr ${FILE}
  # usually we will only decript though

  echo "Decrypting ${FILE}"
  gpg -o ${FILE} -d ${FILE}.encr

  echo "* After decrypting ${FILE}"
  ls ${FILE}*

  echo .
}

function dstrader_clear() {
  FILE=$1
  echo "Clear ${FILE}"
  shred -un 3 ${FILE}

  echo "* After clear ${FILE}"
  ls ${FILE}*

  echo .
}


DIR1=$2
DIR2="$( cd -- "${DIR1}/../../ib" >/dev/null 2>&1 ; pwd -P )"

echo $DIR1
echo $DIR2

# always try encrypting
echo NOTE: Always try encrypting first to hide clear text file

case "$1" in
  setup)
    gpg --full-generate-key
    ;;
  decrypt)
    cd "$DIR1" ; dstrader_encr mail.properties          ; dstrader_decr mail.properties
    cd "$DIR2" ; dstrader_encr IBController.ini.jdtogni ; dstrader_decr IBController.ini.jdtogni
    ;;
  clear)
    cd "$DIR1" ; dstrader_encr mail.properties          ; dstrader_clear mail.properties
    cd "$DIR2" ; dstrader_encr IBController.ini.jdtogni ; dstrader_clear IBController.ini.jdtogni
    ;;
  *)
    echo "Usage: encr_files.sh {decrypt|clear}"
    exit 1
esac

exit 0
