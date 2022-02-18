#!/bin/bash

echo -e "${GREY}\tHello from prod. Start you app here.${OFF}"

# Below is an example that
# will start a process in the background (if ${DETACH} is true, otherwise in the foreground)
# and will save the PID of that process so that we can stop it later (see stop.sh)

# The actual command to start your app process
START_COMMAND="sleep 10"

if [ "${DETACH}" = true ]; then
    # This will start the process and store the pid of the process
    START_COMMAND_PID="${START_COMMAND} & echo \$! > ./${PID_FILE_NAME} &"
    # This will let it run in the background
    START_COMMAND_NOHUP="nohup bash -c '${START_COMMAND_PID}' > start.out 2> start.err < /dev/null &"
    eval "${START_COMMAND_NOHUP}"
else
    # This will let it run in the foreground
    ${START_COMMAND} || exit 1
fi
