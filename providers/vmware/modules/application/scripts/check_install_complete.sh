#!/bin/bash -x

LOG_FILE="/var/log/cloud-init.log"
SUCCESS_STRING="SUCCESS: running modules for final"
RETRIES=120
SLEEP_TIME=10

for (( i=0; i<=$RETRIES; i++ )); do
    if [[ -f "${LOG_FILE}" ]]  && egrep "${SUCCESS_STRING}" "${LOG_FILE}"; then
      echo 'Install Complete' > /var/tmp/INSTALL_COMPLETE
      break
    else
      echo "Waiting for install complete. sleeping ${SLEEP_TIME} seconds"
      sleep ${SLEEP_TIME}
    fi
done

if [[ -f "/var/tmp/INSTALL_COMPLETE" ]]; then
  echo 'Install Complete'
else
  echo 'Install Failed'
  exit 1
fi