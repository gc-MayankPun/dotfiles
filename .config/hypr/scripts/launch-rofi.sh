#!/bin/bash

# Prevent multiple instances of rofi running
pgrep -x rofi && exit

# If no argument was passed, exit with error
[[ -z "$1" ]] && {
    echo "No command provided."
    exit 1
}

# Special case: clipboard
if [[ "$1" == "clipboard" ]]; then
    # Run clipboard menu
    cliphist list | rofi -dmenu | cliphist decode | wl-copy
    exit 0
fi

# If first word is 'rofi', allow it with arguments
if [[ "$1" == "rofi" ]]; then
    shift
    rofi "$@"
    exit 0
fi 

# If none matched
echo "Error: '$1' is not an allowed command."
exit 1
