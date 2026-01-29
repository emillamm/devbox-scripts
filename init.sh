#!/usr/bin/env bash
# Source this file in your devbox.json init_hook to set up devbox-scripts
# Usage: source ./devbox-scripts/init.sh

DEVBOX_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEVBOX_SCRIPTS_DIR
export PATH="$DEVBOX_SCRIPTS_DIR:$PATH"
