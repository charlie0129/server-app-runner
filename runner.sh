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

if [ "$VERBOSE" = true ]; then
    echo -e "${HEADER_INFO}operation  = ${BOLD}${COMMAND}${OFF}"
    echo -e "${HEADER_INFO}skip_build = ${BOLD}${SKIP_BUILD}${OFF}"
    echo -e "${HEADER_INFO}silent     = ${BOLD}${SILENT}${OFF}"
fi
