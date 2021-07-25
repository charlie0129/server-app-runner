#!/bin/bash

echo -e "${GREY}\tHello from prod. Stop you app here.${OFF}"

# This is an example that will read the saved PID of a started process and stop it
# See how to start and save PID in start.sh

PID="$(cat ./${PID_FILE_NAME})"
IMAGE="$(ps -p "${PID}" -o comm=)"

if [ "${IMAGE}" != "" ]; then
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}killing process, pid=${BOLD}${PID}${OFF} image=${BOLD}${IMAGE}${OFF} "
    fi
    kill "${PID}"
else
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}pid=${GREY}${PID}${OFF} does not exist, skipping..."
    fi
fi

exit 0
