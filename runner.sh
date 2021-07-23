#!/bin/bash

# Display style setting
BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
OFF="\033[m"

HEADER_INFO="${BLUE}[INFO]$OFF "
HEADER_WARN="${YELLOW}[WARN]$OFF "
HEADER_ERROR="${RED}[ERROR]$OFF "

PID_FILE_NAME="started_process.pid"

SKIP_BUILD=false
SILENT=false
VERBOSE=false

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    start)
        COMMAND=start
        shift # past argument
        ;;
    build)
        COMMAND=build
        shift # past argument
        ;;
    stop)
        COMMAND=stop
        shift # past argument
        ;;
    update)
        COMMAND=stop
        shift # past argument
        ;;
    --skip-build)
        SKIP_BUILD=true
        shift # past argument
        ;;
    -s | --silent)
        SILENT=true
        shift # past argument
        ;;
    -v | --verbose)
        VERBOSE=true
        shift
        ;;
    *) # unknown option
        echo -e "${HEADER_ERROR}Unknown argument: $1"
        exit 1
        ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "${VERBOSE}" = true ]; then
    echo -e "${HEADER_INFO}operation  = ${YELLOW}${COMMAND}${OFF}"
    echo -e "${HEADER_INFO}skip_build = ${YELLOW}${SKIP_BUILD}${OFF}"
    echo -e "${HEADER_INFO}silent     = ${YELLOW}${SILENT}${OFF}"
fi

handle_error() {
    echo -e "${HEADER_ERROR}$1 failed"
    exit 1
}

build() {
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}building..."
    fi
    bash ./runner_scripts/build.sh || handle_error "build"
}

start() {
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}pre-starting..."
    fi
    bash ./runner_scripts/pre_start.sh || handle_error "pre-start"

    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}application starting..."
    fi

    START_COMMAND="$(head -n1 ./runner_scripts/start.sh)"

    if [ "${SILENT}" = true ]; then
        START_COMMAND_PID="${START_COMMAND} & echo \$! > ./${PID_FILE_NAME} &"
        START_COMMAND_NOHUP="nohup bash -c '${START_COMMAND_PID}' > start.out 2> start.err < /dev/null &"
        eval "${START_COMMAND_NOHUP}"
    else
        ${START_COMMAND} || handle_error "start"
    fi

}

case $COMMAND in
start)
    if [ "${SKIP_BUILD}" = false ]; then
        build
    fi
    start
    ;;
build)
    build
    ;;
stop)
    kill "$(cat ./${PID_FILE_NAME})"
    ;;
update)
    bash ./runner_scripts/update.sh || handle_error "update"
    ;;
*) ;;
esac
