#!/bin/bash

# Colors
BOLD="\033[1m"
GREY="\033[1;30m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
OFF="\033[m"

HEADER_INFO="${BLUE}[INFO]$OFF "
HEADER_WARN="${YELLOW}[WARN]$OFF "
HEADER_ERROR="${RED}[ERROR]$OFF "

# The file used to store the pid of a proviously started background process
PID_FILE_NAME="started_process.pid"

# Default state
SKIP_BUILD=false
SILENT=false
VERBOSE=false

# List environments in current directory
ENV_LIST=$(ls -d runner_scripts*)
ENV_LIST=${ENV_LIST[@]//runner_scripts_/}
ENV_LIST=(${ENV_LIST})

function usage() {
    echo -e "server-app-runner"
    echo -e ""
    echo -e "./runner.sh"
    echo -e "\t start:        build your project, stop a previous process, then start a new one"
    echo -e "\t build:        build your project"
    echo -e "\t stop:         stop a previously started background process"
    echo -e "\t update:       update your project"
    echo -e "\t --skip-build: skip build process when during \"start\""
    echo -e "\t -s --silent:  start project in the background and return"
    echo -e "\t -v --verbose: trun on verbose mode"
    echo -e "\t -h --help:    show this help and exit"
    echo -e ""
}

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Check if a string is a valid environment
check_is_valid_env() {
    # if $1 is in ENV_LIST
    if containsElement "$1" "${ENV_LIST[@]}"; then
        return 0
    fi

    case $1 in
    "" | --skip-build | -s | --silent | -v | --verbose)
        return 1
        ;;
    *)
        echo -e "${HEADER_ERROR}Unknown environment: ${YELLOW}$1${OFF}. Available environment(s): ${GREEN}${ENV_LIST[@]}${OFF}"
        exit 1
        ;;
    esac
}

# Parse auguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    start)
        COMMAND=start
        RUNNER_ENV="$2"
        check_is_valid_env "$2" && shift
        shift
        ;;
    build)
        COMMAND=build
        RUNNER_ENV="$2"
        check_is_valid_env "$2" && shift
        shift
        ;;
    stop)
        COMMAND=stop
        shift
        ;;
    update)
        COMMAND=update
        RUNNER_ENV="$2"
        check_is_valid_env "$2" && shift
        shift
        ;;
    --skip-build)
        SKIP_BUILD=true
        shift
        ;;
    -s | --silent)
        SILENT=true
        shift
        ;;
    -v | --verbose)
        VERBOSE=true
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo -e "${HEADER_ERROR}Unknown argument: $1"
        echo ""
        usage
        exit 1
        ;;
    esac
done

# restore positional parameters
set -- "${POSITIONAL[@]}"

# Check arguments
if [ "${SKIP_BUILD}" = true ] && [ "${COMMAND}" != start ]; then
    echo -e "${HEADER_ERROR}You can only pair --skip-build with \"start\""
    exit 1
fi

if [ "${SILENT}" = true ] && [ "${COMMAND}" != start ]; then
    echo -e "${HEADER_ERROR}You can only pair -s --silent with \"start\""
    exit 1
fi

# Check environment (RUNNER_ENV)
case $RUNNER_ENV in
"" | --skip-build | -s | --silent | -v | --verbose)
    if [ "${COMMAND}" != stop ]; then
        echo -e "${HEADER_WARN}No environment set, falling back to ${ENV_LIST[0]}"
    fi
    RUNNER_ENV=${ENV_LIST[0]}
    ;;
*)
    ;;
esac

# Show configuration (verbose)
if [ "${VERBOSE}" = true ]; then
    echo -e "${HEADER_INFO}operation   = ${GREEN}${COMMAND}${OFF}"

    echo -e "${HEADER_INFO}environment = ${GREEN}${RUNNER_ENV}${OFF}"

    COLOR=$([ "${SKIP_BUILD}" = true ] && echo "${GREEN}" || echo "${GREY}")
    echo -e "${HEADER_INFO}skip_build  = ${COLOR}${SKIP_BUILD}${OFF}"

    COLOR=$([ "${SILENT}" = true ] && echo "${GREEN}" || echo "${GREY}")
    echo -e "${HEADER_INFO}silent      = ${COLOR}${SILENT}${OFF}"
fi

# Define some functions

handle_error() {
    echo -e "${HEADER_ERROR}$1 failed"
    exit 1
}

build() {
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}building..."
    fi
    bash ./runner_scripts_"${RUNNER_ENV}"/build.sh || handle_error "build"
}

start() {
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}pre-starting..."
    fi
    bash ./runner_scripts_"${RUNNER_ENV}"/pre_start.sh || handle_error "pre-start"

    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}application starting..."
    fi

    START_COMMAND="$(head -n1 ./runner_scripts_"${RUNNER_ENV}"/start.sh)"

    if [ "${SILENT}" = true ]; then
        # This will start the process and store the pid of the process
        START_COMMAND_PID="${START_COMMAND} & echo \$! > ./${PID_FILE_NAME} &"
        # This will let it run in the background
        START_COMMAND_NOHUP="nohup bash -c '${START_COMMAND_PID}' > start.out 2> start.err < /dev/null &"
        eval "${START_COMMAND_NOHUP}"
    else
        ${START_COMMAND} || handle_error "start"
    fi

}

stop() {
    PID="$(cat ./${PID_FILE_NAME})"
    IMAGE="$(ps -p "${PID}" -o comm=)"
    if [ "${VERBOSE}" = true ]; then
        echo -e "${HEADER_INFO}killing pid=${PID} image=\"${IMAGE}\" "
    fi
    kill "${PID}"
}

# Actually run the scripts
case $COMMAND in
start)
    if [ "${SKIP_BUILD}" = false ]; then
        build
    fi
    stop 2>/dev/null
    start
    ;;
build)
    build
    ;;
stop)
    stop
    ;;
update)
    bash ./runner_scripts_"${RUNNER_ENV}"/update.sh || handle_error "update"
    ;;
*)
    echo -e "${HEADER_ERROR}You need to specify an operation"
    usage
    ;;
esac
