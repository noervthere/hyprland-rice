#!/bin/bash

PANEL_NAME=$1
DIR="$HOME/.config/quickshell/components"

# Check if the specific quickshell panel is running
if pgrep -f "quickshell -p $DIR/$PANEL_NAME" > /dev/null; then
    # If running, kill it to close the panel
    pkill -f "quickshell -p $DIR/$PANEL_NAME"
else
    # If not running, launch it
    quickshell -p "$DIR/$PANEL_NAME" &
fi
