#while inotifywait -e modify /tmp/xplr$@; do
#    if [[ $(cat /tmp/xplr$@) = "" ]]
#    then 
#        continue
#    fi
#    # Execute your desired action here
#    echo [info]: $@ Changed
#    # You can also send a signal to Neovim, e.g., to trigger a specific command.
#    pkill -SIGUSR1 -P $(($@-3))
#done
#!/bin/bash

# Set a lock file path
LOCKFILE="/tmp/xplr_lock$@"
while inotifywait -e modify /tmp/nvxplr/xplr$@; do
    # Check if the lock file exists
    if [ -e "$LOCKFILE" ]; then
        echo "[info]: Waiting for lock to be released..."
        sleep 1
        continue
    fi

    # Create a lock file
    touch "$LOCKFILE"

    if [[ $(cat /tmp/nvxplr/xplr$@) = "" ]]; then
        # Release the lock file
        rm "$LOCKFILE"
        continue
    fi

    # Execute your desired action here
    echo "[info]: $@ Changed"

    # Release the lock file
    rm "$LOCKFILE"

    if [ -d /tmp/nvxplr/xplr$@ ]; then
        pkill -SIGUSR2 -P $(($@-3))
    else
        pkill -SIGUSR1 -P $(($@-3))
    fi
done
