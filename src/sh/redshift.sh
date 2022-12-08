#!/bin/bash

# fixed because im an idiot who doesn't know to use the wait command

LOCKDIR=~/.config/awesome/cache/redshift_lock

function cleanup {
    if rm -r $LOCKDIR; then
        echo "Finished"
    else
        echo "Failed to remove lock dir $LOCKDIR"

        exit 1
    fi

    kill $REDSHIFT_PID
}

REDSHIFT_ENABLED=1
function toggle {
    if [ -z "$REDSHIFT_PID" ]; then
        return
    fi

    REDSHIFT_ENABLED=$((1-REDSHIFT_ENABLED))

    # Update enabled state
    check

    kill -usr1 $REDSHIFT_PID
}

function check {
    echo "check"

    echo $REDSHIFT_ENABLED > $LOCKDIR/enabled
}

if mkdir $LOCKDIR  > /dev/null 2>&1; then
    trap "cleanup" SIGTERM SIGINT

    echo "Aquired lock, running"

    trap "toggle; wait" USR1

    trap "check; wait" USR2
    
    echo $BASHPID > $LOCKDIR/pid

    # Geoclue
    /usr/lib/geoclue-2.0/demos/agent &

    redshift &

    REDSHIFT_PID=$!

    wait
else
    PARENT_PID=`cat $LOCKDIR/pid`

    if [ "$1" = "check" ]; then
        kill -s usr2 $PARENT_PID

        cat $LOCKDIR/enabled
    elif [ "$1" = "toggle" ]; then
        kill -s usr1 $PARENT_PID
    else
        echo "Redshift child process: use 'check' or 'toggle'"
        echo "redshift.sh <check|toggle>"
    fi
fi  