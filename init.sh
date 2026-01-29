#!/bin/sh
# Source this file in your devbox.json init_hook to set up devbox-scripts
# Requires DEVBOX_SCRIPTS_DIR to be set in devbox.json env section

export PATH="$DEVBOX_SCRIPTS_DIR:$PATH"
