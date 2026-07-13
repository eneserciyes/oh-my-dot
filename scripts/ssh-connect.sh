#!/bin/bash
# Connect to an ssh host. When run inside tmux, name the window after the host
# while connected and restore the previous naming behaviour on exit.

host=$1
[[ ! $host ]] && exit 0

if [[ -n $TMUX ]]; then
    old_auto=$(tmux show-window-options -v automatic-rename 2>/dev/null)
    old_name=$(tmux display-message -p '#W')
    tmux rename-window "$host"
fi

ssh "$host"
status=$?

if [[ -n $TMUX ]]; then
    # automatic-rename defaults to on; manually naming a window turns it off.
    if [[ $old_auto == "off" ]]; then
        tmux rename-window "$old_name"
    else
        tmux set-window-option automatic-rename on
    fi
fi

exit $status
