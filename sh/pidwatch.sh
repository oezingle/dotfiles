#!/bin/bash

# pidwatch <parent process name> <child process command...>

# pidwatch kills the child when the parent dies

PARENT_NAME=$1
PARENT_PID=$(pidof ${PARENT_NAME} | awk '{print($1)}')

if [[ -z $PARENT_PID ]]; then
    echo "ERROR: No PID found for parent process"
    
    exit 1
fi

eval "${@:2} &"

CHILD_PID=$!
CHILD_NAME=$(ps --pid $CHILD_PID -o comm h)

if [[ -z $CHILD_NAME ]]; then
    echo "Child process already exited"

    exit 0
fi

echo "Parent
    PID: ${PARENT_PID} NAME: ${PARENT_NAME}
Child
    PID: ${CHILD_PID} NAME: ${CHILD_NAME}"

while true; do
    CHILD_TEST_NAME=$(ps --pid $CHILD_PID -o comm h)

    if [ "$CHILD_NAME" != "$CHILD_TEST_NAME" ]; then
        echo "Child process exited itself"

        exit 0
    fi

    PARENT_TEST_NAME=$(ps --pid $PARENT_PID -o comm h)

    if [ "$PARENT_NAME" != "$PARENT_TEST_NAME" ]; then
        echo "Parent process dead"
        
        kill "$CHILD_PID"
    fi

    sleep 60
done    